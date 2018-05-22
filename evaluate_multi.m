function [accuracy,con_mat] = evaluate_multi(min_index, tot_trial, class)

 
classlabel = [];
for(l = 1:tot_trial)
    for(k =1:class)
        classlabel = [classlabel k];
    end
end

c1 = find(classlabel==1); %classlabel이 1일때의 index
c2 = find(classlabel==2);
c3 = find(classlabel==3);
c4 = find(classlabel==4);
c5 = find(classlabel==5);
% 
%       
r1=min_index(c1); %classlabel 이 1일때의 결과값의 벡터
r2=min_index(c2);
r3=min_index(c3);
r4=min_index(c4);
r5=min_index(c5);


con_mat11=length(find(r1==1));
con_mat21=length(find(r1==2));
con_mat31=length(find(r1==3));
con_mat41=length(find(r1==4));
con_mat51=length(find(r1==5));

con_mat12=length(find(r2==1));
con_mat22=length(find(r2==2));
con_mat32=length(find(r2==3));
con_mat42=length(find(r2==4));
con_mat52=length(find(r2==5));

con_mat13=length(find(r3==1));
con_mat23=length(find(r3==2));
con_mat33=length(find(r3==3));
con_mat43=length(find(r3==4));
con_mat53=length(find(r3==5));

con_mat14=length(find(r4==1));   
con_mat24=length(find(r4==2));   
con_mat34=length(find(r4==3));   
con_mat44=length(find(r4==4));  
con_mat54=length(find(r4==5));  

con_mat15=length(find(r5==1));   
con_mat25=length(find(r5==2));   
con_mat35=length(find(r5==3));   
con_mat45=length(find(r5==4));  
con_mat55=length(find(r5==5));  
 
%confusion matrix
con_mat = [con_mat11 con_mat12 con_mat13 con_mat14 con_mat15; con_mat21 con_mat22 con_mat23 con_mat24 con_mat25; ...
    con_mat31 con_mat32 con_mat33 con_mat34 con_mat35; con_mat41 con_mat42 con_mat43 con_mat44 con_mat45; con_mat51 con_mat52 con_mat53 con_mat54 con_mat55;];
    
accuracy = (con_mat11+con_mat22+con_mat33+con_mat44+con_mat55)/(tot_trial*class);

% N= n_trial*class;
% con_mat_row = sum(con_mat, 2);
% con_mat_col = sum(con_mat, 1);
% p_e = sum(con_mat_row'.*con_mat_col)/N^2;


% kappa_coef= (accuracy-p_e)/(1-p_e);
    