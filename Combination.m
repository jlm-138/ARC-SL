%2019.8.25
%子函数：生成规则的结论项
%input: Activated_degree--1*M cell; Discounted_factor--1*M 行向量
%Output:Combination_result--1*M 行向量

function  Combination_result=Combination(Activated_degree,Discounted_factor)

M=length(Activated_degree); %存储类别数目
Mass=zeros(1,M+1); %存储没有被归一化的mass融合结果
temp1=ones(1,M); %存储一个连乘积的值
temp2=ones(1,M); %存储求全集连乘中的元素
for s=1:M
    if isempty(Activated_degree{1,s})==0
        temp1(1,s)=prod(ones-Activated_degree{1,s});
        temp2(1,s)=Discounted_factor(1,s)*temp1(1,s)+1-Discounted_factor(1,s);
    end
end

%下面给出相应的mass值
Mass(1,M+1)=prod(temp2); 
for s=1:M
    Mass(1,s)=Discounted_factor(1,s)*(1-temp1(1,s))*prod(temp2(1,[1:s-1 s+1:M]));
end

%下面进行归一化
Combination_result=zeros(1,M+1);
for s=1:M+1
    Combination_result(1,s)=Mass(1,s)/sum(Mass); 
end

end


