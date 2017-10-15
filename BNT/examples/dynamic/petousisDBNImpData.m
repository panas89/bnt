clear;clc;
warning('off', 'Octave:possible-matlab-short-circuit-operator');
intra = zeros(3);
intra(1,2) = 1; 
intra(1,3) = 1;

inter = zeros(3);
inter(1,1) = 1; 

Q = 3; % num hidden states
O1 = 8; % num observable symbols
O2 = 2;
ns = [Q O1 O2];%number of states
dnodes = 1:3;
%onodes = 2; % only possible with jtree, not hmm
%onodes = [2]; 
bnet = mk_dbn(intra, inter, ns, 'discrete', dnodes);%, 'observed', onodes);
for i=1:4
  bnet.CPD{i} = tabular_CPD(bnet, i,'CPT','rnd');
end

prior0 = normalise(rand(Q,1));
transmat0 = mk_stochastic(rand(Q,Q));
obsmat0 = mk_stochastic(rand(Q,O1));
obsmat1 = mk_stochastic(rand(Q,O2));


%engine = smoother_engine(hmm_2TBN_inf_engine(bnet));
engine = smoother_engine(jtree_2TBN_inf_engine(bnet));

%%%%%%%%%%%%%%%%%%%%%%%% create cases from dataset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ss = 3;%slice size(ss)
ncases = 10;%number of examples
T=5;

%data = randi(3,T*ss);
%data(1,2) = NaN;data(3,2) = NaN;data(6,3) = NaN;data(4,5) = NaN;data(5,5) = NaN;
data = dlmread("./Data/DataNodObs/dfDBNTrainNum.csv");

sizeData = size(data);
ncases = sizeData(1);
ncolumns = sizeData(2);

max_iter=2;%iterations for EM
cases = cell(1, ncases);
for i=1:ncases
  cases{i} = cell(ss,T);
  for j=1:ncolumns
    if data(i,j)==0
      cases{i}{j} = [];
    else
      cases{i}{j} = data(i,j);
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[bnet2, LLtrace] = learn_params_dbn_em(engine, cases, 'max_iter', 150);

for i=1:4
  struct(bnet2.CPD{i}).CPT
end

