function [train, test, data1] = data_separate2(data, crossval)
% data_separate���� test��������ġ circshift�� �ٲ�.
% data_separate1���� ��� crossvalidation �����ͼ�Ʈ ������� �ʰ� train, test ������
% ������ circshift�ؼ� ���.

condition_num = length(data);
data_size = size(data{1}, 2);

% tot_block = num_trial*dividing;
% block_num = tot_block/crossval;
% blocksize = (time(2)-time(1))/1000*sampling_rate*num_block;
block_size = data_size/crossval;

train = cell(1, condition_num);
test = cell(1, condition_num);


for j= 1:condition_num
%     train{j} = data{j}(:,1:data_size-block_size);
%     test{j} = data{j}(:,data_size-block_size+1:data_size);
    
    test{j} = data{j}(:,1:block_size);
    train{j} = data{j}(:,block_size+1:data_size);
    
    data1{j} = circshift(data{j}, [0 -block_size]);
end