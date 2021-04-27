%�Ӻ���:����ģ��ǰ�����Ӧ��֧�ֶ� 
%input��itemset--ǰ�������1*P��
%       Data-- cell(1,N),ÿ��ѵ��������ÿ��ģ�������µ������ȵ�ֵ��N��ѵ��������Ŀ
%output��Sup_item-ǰ��itemset��֧�ֶ�ֵ
%������ǰ�������µ�������ֵ�ǰ��ռ������ӣ��˻��Ļ����ϼ�һ���ݴΣ�

function [Value,Matching_degree]=Support(itemset,Data)

N=length(Data);  %��ʾ����ѵ�������ĸ���
Matching_degree=zeros(1,N);
sum=0;
Non_zero=find(itemset);  %��ʾǰ������Щ����ֵ���㣿
Number=size(Non_zero,2); %��ʾ��������е����Ը���

for i=1:N
    temp=zeros(1,Number);
    for j=1:Number
        temp(1,j)=Data{1,i}{Non_zero(j),1}(1,itemset(1,Non_zero(j)));
        if temp(1,j)==0
            break
        end
    end
    %row=row+1;
    %Membership_matrix(row,:)=temp;
    %����һ��
    %sum=sum+(prod(temp)); %����ȶ���ֱ���ǳ˻�����ʽ
    %��������
    Matching_degree(1,i)=(prod(temp))^(1/Number);
    sum=sum+Matching_degree(1,i);  %�ڷ���һ�Ļ����ϳ�����һ���ݴ�
    
    %�����������˻����Ӹ�Ϊ��С����
%     sum=sum+min(temp); 
end

Value=sum/N;


    





