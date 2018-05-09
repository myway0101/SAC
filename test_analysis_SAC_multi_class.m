function [min_index, run_time, avg_r] = test_analysis_SRC_seizure(test,dictionary,tot_trial, srate, L)

decision = 0;

condition_num = size(test,2);
[ch_num, data_size] = size(test{1});

test_num1 = data_size;
train_num = size(dictionary,2)/condition_num;

decision = zeros(condition_num, test_num1);
AU1 = dictionary(:,1:size(dictionary,2)/2);
AU2 = dictionary(:,(size(dictionary,2)/2)+1:end);
D = dictionary ;%(nxm)
D_1 = [];
D_2 = [];
run_time = 0;
tot_r = [];
min_index = [];

for j = 1:test_num1
    for i = 1:condition_num
        y= test{i}(:,j);
        y = y/(diag(sqrt(diag(y'*y))));
        
        if(i==1)
            D_1 = [y];
        else
            D_2 = [y];
        end
        %         D = dictionary ;%(nxm)
        Y = y;
        A = D;
        N=size(D,2);
        
        %ell-1 min
        %       addpath('.\l1benchmark\L1Solvers')
        tic;
        if L == 1
            sol = SolveBP(A,Y,N );
        elseif L == 2
            [sol,total_iter, timeSteps] = SolveFISTA(A,Y);
            
        elseif L == 3
            [sol,total_iter, timeSteps] = SolveHomotopy(A, Y);
            
        elseif L == 4
            sol = SolveL1LS(A, Y);
            
            %         elseif L == 5
            %             sol = SolveAMP(A,Y);
            %         elseif L == 5
            %             sol = SolveSpaRSA(A,Y);
            
        elseif L == 5    % pseudo inverse
            Proj_M = inv(A'*A)*A';
            sol = Proj_M * Y;
            
        end
        
        t=toc;
        run_time = run_time + t;
        X=sol;
        
        %compute residue
        %% compute residual
        % total residual
        tot_r = [tot_r norm(Y-(D*X))];
        avg_r = mean(tot_r);
        % class residual
        
        X_c1= zeros(train_num*condition_num,1);
        X_c2= zeros(train_num*condition_num,1);
        X_c3= zeros(train_num*condition_num,1);
        X_c4= zeros(train_num*condition_num,1);
        %         X_c5= zeros(train_num*condition_num,1);
        
        for(i=1:train_num)
            X_c1(i)= X(i);
            X_c2(i+train_num)= X(i+train_num);
            X_c3(i+train_num*2)= X(i+train_num*2);
        end
        
        c1_norm=norm(Y-D*X_c1);
        c2_norm=norm(Y-D*X_c2);
        c3_norm=norm(Y-D*X_c3);
        norms = [c1_norm, c2_norm, c3_norm];
        index = find(norms == min(norms));
        min_index = [min_index index];
        
    end
    
end



