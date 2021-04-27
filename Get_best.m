%子函数：在L_index+1到R_index-1个可能的边界点中寻找熵最小的划分点
%Revised by JLM on 2020-05-26
function [IndexBestCut,Index_left,Index_right,EntS1,EntS2,EntS,Entropy_min,L1,L2]=Get_best(BoundaryPoints,L_index,R_index,X,Label_Mass,Num_Initial)

Num_boundary=R_index-L_index-1;
Index_left=cell(Num_boundary,1); %存储在每个边界点左边的数据索引位置
Index_right=cell(Num_boundary,1); %在边界点右边的数据索引位置
EntS1=zeros(Num_boundary,1); %每个边界点左侧对应样本集的熵值
EntS2=zeros(Num_boundary,1); %每个边界点右侧对应样本集的熵值
Entropy=zeros(Num_boundary,1); %用来存储E（A,T;S）
L1=zeros(Num_boundary,1);
L2=zeros(Num_boundary,1);

for i=L_index+1:R_index-1
    %先表示左右索引值对应的边界点之间的属性值数据对应的位置
    if L_index<1
        Index_left{i-L_index,1}=find(X<BoundaryPoints(i));
    else
        Index_left{i-L_index,1}=find(BoundaryPoints(L_index)<X & X<BoundaryPoints(i));
    end
    
    if R_index>Num_Initial
        Index_right{i-L_index,1}=find(X>BoundaryPoints(i));
    else
        Index_right{i-L_index,1}=find(BoundaryPoints(i)<X & X<BoundaryPoints(R_index));
    end
    
    %求以第i个边界点为切割点的熵值
    EntS1(i-L_index,1)=Entropy_interval(Index_left{i-L_index,1},Label_Mass); %调用子函数，求第i个边界点左边数据的熵值
    EntS2(i-L_index,1)=Entropy_interval(Index_right{i-L_index,1},Label_Mass); %求第i个边界点右边数据的熵值
    
    %求以第i个边界点为切割点的熵值（利用Pignistic）
%     EntS1(i-L_index,1)=Entropy_interval_pignistic(Index_left{i-L_index,1},Label_Mass); %调用子函数，求第i个边界点左边数据的熵值
%     EntS2(i-L_index,1)=Entropy_interval_pignistic(Index_right{i-L_index,1},Label_Mass); %求第i个边界点右边数据的熵值
    
    %下面对第i个边界点所求出的熵值进行判定，求出增益值
    L1(i-L_index,1)=length(Index_left{i-L_index,1}); %在边界点左边的样本数目
    L2(i-L_index,1)=length(Index_right{i-L_index,1}); %在边界点右边的样本数目
    N=L1(i-L_index,1)+L2(i-L_index,1);
    Entropy(i-L_index,1)=L1(i-L_index,1)*EntS1(i-L_index,1)/N+L2(i-L_index,1)*EntS2(i-L_index,1)/N;
end
Index_all=[Index_left{1,1};Index_right{1,1}];%表示所考虑的样本集合中的所有样本属性值对应的索引
EntS=Entropy_interval(Index_all,Label_Mass); %表示的是Entropy(S)
% EntS=Entropy_interval_pignistic(Index_all,Label_Mass); %表示的是Entropy(S)（利用Pignistic）
[Entropy_min,Index]=min(Entropy);
IndexBestCut = Index + L_index;  
end

