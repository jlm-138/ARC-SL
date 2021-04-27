%2020.7.30--
%子函数，输出前提项Item和结论项<Item,s>的支持度
%输入：Class_set-1*M cell,类标签集合， s--对应Class_set中的哪一个类别
%      Label_mass--N*2cell, 每个训练样本的软标签以及对应的Mass值

function [Sup_item,Sup_ruleitem]=Support_Ruleitem(itemset,Data,Class_set,s,Label_mass)

N=length(Data);  %表示的是训练样本的个数
Matching_degree=zeros(1,N);
Sup_item=0;
Sup_ruleitem=0;
Non_zero=find(itemset);  %表示前提中哪些属性值非零？
Number=size(Non_zero,2); %表示项集中所含有的属性个数

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
       Sup_item=Sup_item+Matching_degree(1,i);  %在方案一的基础上乘以了一个幂次
       if isequal(Label_mass{i,1},Class_set{1,s})==1
           Sup_ruleitem=Sup_ruleitem+Matching_degree(1,i)*Label_mass{i,2}+(1-Matching_degree(1,i))*(1-Label_mass{i,2});
       end
    end
end
Sup_ruleitem=Sup_ruleitem/N;
Sup_item=Sup_item/N;


    





