%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% SAC SEIZURE DETECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2017_11_06 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Author: Younghak Shin
% Email: shinyh0919@gmail.com 
% Last update: 2017.11.06

% Z,O,N,F,S ===== A,B,C,D,E

clear
clc

% add path for L1 norm minimization algorithms
addpath('.\l1benchmark\L1Solvers')

%% DATA LOAD 
orig_trial = 100;
time_samples = 4096; 

for(j = 1:5)
    for(i=1:orig_trial)
        data{j,i} = data_LOAD(i,j);
    end
end
data = cell2mat(data);

srate = 173.61;

freq_BP=[0.1 49]; % for band-pass filtering
order = 4; % BW filter order
crossval = 10; % N-fold cross validation
condition_num = 2; % two-class

A = data(1,:);
B = data(2,:);
C = data(3,:);
D = data(4,:);
E = data(5,:);

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

%% data setup 4096 * 100
for (k = 1:orig_trial)
    data_A2 = [data_A2; data_A1(:, (k-1)*trial_sample+1:(trial_sample*k)-1)];
    data_B2 = [data_B2; data_B1(:, (k-1)*trial_sample+1:(trial_sample*k)-1)];
    data_C2 = [data_C2; data_C1(:, (k-1)*trial_sample+1:(trial_sample*k)-1)];
    data_D2 = [data_D2; data_D1(:, (k-1)*trial_sample+1:(trial_sample*k)-1)];
    data_E2 = [data_E2; data_E1(:, (k-1)*trial_sample+1:(trial_sample*k)-1)];
end
data_A3 = data_A2';
data_B3 = data_B2';
data_C3 = data_C2';
data_D3 = data_D2';
data_E3 = data_E2';

data_A = data_A3(1:time_samples, :);  % time samples per epoch
data_B = data_B3(1:time_samples, :);
data_C = data_C3(1:time_samples, :);
data_D = data_D3(1:time_samples, :);
data_E = data_E3(1:time_samples, :);

final_sample = size(data_A, 1);
sel_time = final_sample/srate;
tot_trial = size(data_A,2);


%% select classification
% class_names = {'data_D', 'data_E'};

class1_n = ['class1 = data_D;'];
% class1_n = ['class1 = data_A;'];
% class1_n = ['class1 = data_C;'];
% class1_n = ['class1 = data_B;'];
eval(class1_n);
class2_n = ['class2 = data_E;'];
eval(class2_n);

%% evaluation
accuracy=[];
tot_test = tot_trial/crossval;
data = {class1 class2};

L1 = {'BP', 'FISTA', 'homotopy', 'L1LS', 'Pseudo_inv'};

for L = [3] %choose L1 minimization
        for n = 1:crossval
     
            [train, test, data] = data_separate2(data, crossval);
             dictionary = cell2mat(train);
            % normalize a dictionary
            dictionary =  dictionary/(diag(sqrt(diag( dictionary'* dictionary))));
            [decision{n},run_time{n}, avg_r{n}] = test_analysis_SAC(test,dictionary,tot_trial, srate, L);  %solve SAC           

        end

        decision1 = cell2mat(decision);
        run_time1 = cell2mat(run_time);
        avg_r1 = cell2mat(avg_r);
        accuracy_left = ( length(find(decision1(1,:)<0)));
        accuracy_right = length(find(decision1(2,:)>0));
        spec = accuracy_left/ size(decision1,2);
        sens = accuracy_right/ size(decision1,2);
        average_accuracy =  (accuracy_left+accuracy_right)/(size(decision1,2)*2);
        average_runtime = mean(run_time1)/(tot_test*condition_num);
        average_residual = mean(avg_r1)/(tot_test*condition_num);

        disp(sprintf('%s, %s, %s', L1{L}, class1_n, class2_n));
        disp(sprintf('freq=%0.1f~%0.1f, time = %f, fold = %d', freq_BP(1), freq_BP(2), sel_time, crossval));
        
        disp(sprintf('Accuracy: %f', average_accuracy));
        disp(sprintf('Sensitivity: %f', sens));
        disp(sprintf('Specificity: %f', spec));
        disp(sprintf('Runtime: %f', average_runtime));
        disp(sprintf('Residual: %f', average_residual));
end









