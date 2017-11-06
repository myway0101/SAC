function [decision, run_time, avg_r] = test_analysis_SAC(test,dictionary,tot_trial, srate, L)

% Author: Younghak Shin
% Email: shinyh0919@gmail.com 
% Last update: 2017.11.06

decision = 0;
condition_num = size(test,2);
[ch_num, data_size] = size(test{1});

test_num1 = data_size;
train_num = size(dictionary,2)/condition_num;

decision = zeros(condition_num, test_num1);
AU1 = dictionary(:,1:size(dictionary,2)/2);
AU2 = dictionary(:,(size(dictionary,2)/2)+1:end);
D = dictionary ;%(nxm)

run_time = 0;
tot_r = [];

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
        tic;
        if L == 1
            sol = SolveBP(A,Y,N );
        elseif L == 2
            [sol,total_iter, timeSteps] = SolveFISTA(A,Y);       
        elseif L == 3
            [sol,total_iter, timeSteps] = SolveHomotopy(A, Y);
%              [sol,total_iter, timeSteps] = SolveHomotopy_2(A, Y);
        elseif L == 4
            sol = SolveL1LS(A, Y);           
        elseif L == 5    % pseudo inverse
%             Proj_M = inv(A'*A)*A';
             A1 = A'*A;
             Proj_M = inv(A1)*A';
            sol = Proj_M * Y;
        end   
        t=toc;
        run_time = run_time + t;      
        X=sol;

        %% compute residual
        % total residual
        tot_r = [tot_r norm(Y-(D*X))];
        avg_r = mean(tot_r);
        % class residual     
        X_left=[];
        X_right=[];       
        for(m=1:size(AU1,2))
           X_left=[X_left; X(m)];
        end       
        for(n=1:size(AU2,2))
           X_right=[X_right; X(n+size(AU1,2))];
        end       
        z1=zeros(size(AU1,2),1);
        z2=zeros(size(AU2,2),1);
        
        X_left=[X_left;z2];
        X_right=[z1;X_right];
        
        R_left(test_num1)=norm(Y-D*X_left);
        R_right(test_num1)=norm(Y-D*X_right);
        dec_res = R_left(test_num1)-R_right(test_num1);
        
        decision(i,j)=dec_res;     
    end
end



