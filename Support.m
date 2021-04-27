%子函数:计算模糊前提项对应的支持度 
%input：itemset--前提项（集）1*P；
%       Data-- cell(1,N),每个训练样本在每个模糊区间下的隶属度的值，N是训练样本数目
%output：Sup_item-前提itemset的支持度值
%计算多个前提属性下的隶属度值是按照几何算子（乘积的基础上加一个幂次）

function [Value,Matching_degree]=Support(itemset,Data)

N=length(Data);  %表示的是训练样本的个数
Matching_degree=zeros(1,N);
sum=0;
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
    %row=row+1;
    %Membership_matrix(row,:)=temp;
    %方案一：
    %sum=sum+(prod(temp)); %激活度定义直接是乘积的形式
    %方案二：
    Matching_degree(1,i)=(prod(temp))^(1/Number);
    sum=sum+Matching_degree(1,i);  %在方案一的基础上乘以了一个幂次
    
    %方案三：将乘积算子改为最小算子
%     sum=sum+min(temp); 
end

Value=sum/N;


    





