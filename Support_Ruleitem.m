%2020.7.30--
%�Ӻ��������ǰ����Item�ͽ�����<Item,s>��֧�ֶ�
%���룺Class_set-1*M cell,���ǩ���ϣ� s--��ӦClass_set�е���һ�����
%      Label_mass--N*2cell, ÿ��ѵ�����������ǩ�Լ���Ӧ��Massֵ

function [Sup_item,Sup_ruleitem]=Support_Ruleitem(itemset,Data,Class_set,s,Label_mass)

N=length(Data);  %��ʾ����ѵ�������ĸ���
Matching_degree=zeros(1,N);
Sup_item=0;
Sup_ruleitem=0;
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
    Matching_degree(1,i)=(prod(temp))^(1/Number);
    if Matching_degree(1,i)>0
       Sup_item=Sup_item+Matching_degree(1,i);  %�ڷ���һ�Ļ����ϳ�����һ���ݴ�
       if isequal(Label_mass{i,1},Class_set{1,s})==1
           Sup_ruleitem=Sup_ruleitem+Matching_degree(1,i)*Label_mass{i,2}+(1-Matching_degree(1,i))*(1-Label_mass{i,2});
       end
    end
end
Sup_ruleitem=Sup_ruleitem/N;
Sup_item=Sup_item/N;


    





