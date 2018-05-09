%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% MULTI-CLASS SEIZURE DETECTION PROBLEM %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author: Younghak Shin
% Email: shinyh0919@gmail.com
% Last update: 2018.05.09

% Z,O,N,F,S ===== A,B,C,D,E

clear
clc

% addpath('.\l1benchmark\L1Solvers')
orig_trial = 100;

for(j = 1:5)
    for(i=1:orig_trial)
        data{j,i} = data_LOAD(i,j);
    end
end
data = cell2mat(data);

srate = 173.61;

freq_BP=[0.1 49];
order = 4;

crossval = 10;
condition_num = 3;

A = data(1,:);
B = data(2,:);
C = data(3,:);
D = data(4,:);
E = data(5,:);
A1 = mean(reshape(A, 4097, 100),2);
B1 = mean(reshape(B, 4097, 100),2);
C1 = mean(reshape(C, 4097, 100),2);
D1 = mean(reshape(D, 4097, 100),2);
E1 = mean(reshape(E, 4097, 100),2);



%% Bandpass filtering
bpt_data = bandpassfilter_fieldtrip(data, srate,freq_BP, order,'but', 'twopass');

data_A1 = bpt_data(1,:); % eyes open
data_B1 = bpt_data(2,:); % eyes closed
data_C1 = bpt_data(3,:); % inter ictal (opposite hemisphere)
data_D1 = bpt_data(4,:); % inter ictal (seizure area)
data_E1 = bpt_data(5,:); % ictal(seizure area)

% tot_trial = 100;
tot_time = size(data_A1,2)/(orig_trial*srate);

tot_sample = size(data_A1,2);

trial_sample = tot_sample/orig_trial;

data_A2 = [];
data_B2 = [];
data_C2 = [];
data_D2 = [];
data_E2 = [];

%% 4096 * 100
for (k = 1:orig_trial)
    data_A2 = [data_A2; data_A1(:, (k-1)*trial_sample+1:(trial_sample*k)-1)];
    data_B2 = [data_B2; data_B1(:, (k-1)*trial_sample+1:(trial_sample*k)-1)];
    data_C2 = [data_C2; data_C1(:, (k-1)*trial_sample+1:(trial_sample*k)-1)];
    data_D2 = [data_D2; data_D1(:, (k-1)*trial_sample+1:(trial_sample*k)-1)];
    data_E2 = [data_E2; data_E1(:, (k-1)*trial_sample+1:(trial_sample*k)-1)];
end
data_A = data_A2';
data_B = data_B2';
data_C = data_C2';
data_D = data_D2';
data_E = data_E2';

final_sample = size(data_A, 1);
sel_time = final_sample/srate;
tot_trial = size(data_A,2);

accuracy=[];

tot_test = tot_trial/crossval;
data = {data_A data_D data_E};
tot_train = tot_trial-tot_test;

L1 = {'BP', 'FISTA', 'homotopy', 'L1LS', 'Pseudo_inv'};
L = 3;
for n = 1:crossval
    [train, test, data] = data_separate2(data, crossval);
    dictionary = cell2mat(train);
    % normalize a dictionary
    dictionary =  dictionary/(diag(sqrt(diag( dictionary'* dictionary))));
    cohe = dictionary' * dictionary;
    
    [min_index{n},run_time{n}, avg_r{n}] = test_analysis_SAC_multi_class(test,dictionary,tot_trial, srate, L);
    
end
min_index1 = cell2mat(min_index);
run_time1 = cell2mat(run_time);
avg_r1 = cell2mat(avg_r);
average_runtime = mean(run_time1)/(tot_test*condition_num);
average_residual = mean(avg_r1)/(tot_test*condition_num);
class = 3;
[accuracy, con_mat] = evaluate_multi(min_index1, tot_trial, class);
disp(sprintf('%s', L1{L}));
disp(sprintf('freq=%0.1f~%0.1f, time = %f, fold = %d, class = %d', freq_BP(1), freq_BP(2), sel_time, crossval, class));
disp(sprintf('Runtime: %f', average_runtime));
disp(sprintf('Residual: %f', average_residual));
disp(sprintf('Accuracy: %f', accuracy));
con_mat
