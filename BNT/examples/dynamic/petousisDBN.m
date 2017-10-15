clear;clc;
intra = zeros(2);
intra(1,2) = 1; 
inter = zeros(2);
inter(1,1) = 1; 

Q = 2; % num hidden states
O = 2; % num observable symbols
ns = [Q O];%number of states
dnodes = 1:2;
onodes = 1; % only possible with jtree, not hmm
%onodes = [2]; 
bnet = mk_dbn(intra, inter, ns, 'discrete', dnodes, 'observed', onodes);
for i=1:4
  bnet.CPD{i} = tabular_CPD(bnet, i,'CPT','rnd');
end

prior0 = normalise(rand(Q,1));
transmat0 = mk_stochastic(rand(Q,Q));
obsmat0 = mk_stochastic(rand(Q,O));

%engine = smoother_engine(hmm_2TBN_inf_engine(bnet));
engine = smoother_engine(jtree_2TBN_inf_engine(bnet));

%%%%%%%%%%%%%%%%%%%%%%%% create cases from dataset %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ss = 2;%slice size(ss)
ncases = 10;%number of examples
T=3;

data = randi(ss,T*ss);
data(1,2) = NaN;data(3,2) = NaN;data(6,3) = NaN;data(4,5) = NaN;data(5,5) = NaN;

sizeData = size(data);
ncases = sizeData(1);
ncolumns = sizeData(2);

max_iter=2;%iterations for EM
cases = cell(1, ncases);
for i=1:ncases
  cases{i} = cell(ss,T);
  for j=1:ncolumns
    if isnan(data(i,j))
      cases{i}{j} = [];
    else
      cases{i}{j} = data(i,j);
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%ss = 2;%slice size(ss)
%ncases = 10;%number of examples
%T=3;
%max_iter=2;%iterations for EM
%cases = cell(1, ncases);
%for i=1:ncases
%  ev = sample_dbn(bnet, T);
%  cases{i} = cell(ss,T);
%  cases{i}(onodes,:) = ev(onodes, :);
%end
%cases{2}{2}= 2;


[bnet2, LLtrace] = learn_params_dbn_em(engine, cases, 'max_iter', 4);

struct(bnet2.CPD{1}).CPT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
samples = cell(10, 10);
for i=1:nsamples
  samples(:,i) = sample_bnet(bnet);
end