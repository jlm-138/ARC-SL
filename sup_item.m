%子函数:计算模糊前提项对应的支持度 
%input：antecedant item--1*P；Data--cell 1*N 
%output：support(itemset)
function [support_item]=sup_item(itemset,Data)
N=length(Data);  %表示的是训练样本的个数
sum=0;
%P=size(itemset,2); %表示的是属性的个数
Non_zero=find(itemset); %表示前提中哪些属性值非零？
Number=size(Non_zero,2); %表示项集中所含有的属性个数

% Membership_matrix=[]; %列数是前提中含有的模糊区间个数，行数是对应隶属度值均是非零的样本数
% row=0; %表示上述矩阵的行数
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
    %方案一：
    %sum=sum+(prod(temp)); %激活度定义直接是乘积的形式
    %方案二：
    sum=sum+(prod(temp))^(1/Number);  %在方案一的基础上乘以了一个幂次
    
    %方案三：将乘积算子改为最小算子
%     sum=sum+min(temp); 
end
support_item=sum/N;

end
    





