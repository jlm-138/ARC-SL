%�Ӻ���:����ģ��ǰ�����Ӧ��֧�ֶ� 
%input��antecedant item--1*P��Data--cell 1*N 
%output��support(itemset)
function [support_item]=sup_item(itemset,Data)
N=length(Data);  %��ʾ����ѵ�������ĸ���
sum=0;
%P=size(itemset,2); %��ʾ�������Եĸ���
Non_zero=find(itemset); %��ʾǰ������Щ����ֵ���㣿
Number=size(Non_zero,2); %��ʾ��������е����Ը���

% Membership_matrix=[]; %������ǰ���к��е�ģ����������������Ƕ�Ӧ������ֵ���Ƿ����������
% row=0; %��ʾ�������������
for i=1:N
    temp=zeros(1,Number);
    for j=1:Number
        temp(1,j)=Data{1,i}(Non_zero(j),itemset(1,Non_zero(j)));
        if temp(1,j)==0
            break
        end
    end
    %row=row+1;
    %Membership_matrix(row,:)=temp;
    %����һ��
    %sum=sum+(prod(temp)); %����ȶ���ֱ���ǳ˻�����ʽ
    %��������
    sum=sum+(prod(temp))^(1/Number);  %�ڷ���һ�Ļ����ϳ�����һ���ݴ�
    
    %�����������˻����Ӹ�Ϊ��С����
%     sum=sum+min(temp); 
end
support_item=sum/N;

end
    





