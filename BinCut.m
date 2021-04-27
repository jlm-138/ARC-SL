%子函数：在L_index+1到R_index-1个可能的边界点中寻找所有的离散点集，递归函数
%输入：BoundaryPoints--边界点处的属性值；
%      L_index-- 最左边边界点的索引值，当其等于0时，表示在第一个边界点左侧的数据
%      R_index--最右边边界点的索引值。当其等于1时，表示在最后一个边界点右侧的数据
%      Num--表示所初始的边界点数目（寻找第一个二化分点的时候对应的边界点的数目）
%输出：Disc--最终的二划分离散点集合
%Revised by JLM on 2020-05-26
function BinCut(BoundaryPoints,L_index,R_index,X,Ambiguous_label,Label_Mass,Num_Initial)

global Disc

if  R_index-L_index>1
    %调用子函数得到最优划分点对应的索引位置
    [IndexBestCut,Index_left,Index_right,EntS1,EntS2,EntS,Entropy_min,L1,L2]=Get_best(BoundaryPoints,L_index,R_index,X,Label_Mass,Num_Initial);
    Index_left_min=Index_left{IndexBestCut-L_index,1};
    Index_right_min=Index_right{IndexBestCut-L_index,1};
    EntS1_min=EntS1(IndexBestCut-L_index,1);
    EntS2_min=EntS2(IndexBestCut-L_index,1);
    L1_min=L1(IndexBestCut-L_index,1); %在所得到的边界点左边的样本数
    L2_min=L2(IndexBestCut-L_index,1); %在所得到的边界点左边的样本数
    N=L1_min+L2_min; %在所讨论的集合中的样本数
    
    %调用子函数，判断上一步所得到的离散点是不是接受
    [flag,MDLP]=MDLP_Accepted(Index_left_min,Index_right_min,EntS1_min,EntS2_min,EntS,Entropy_min,N,Ambiguous_label,Label_Mass);
    
    if flag==1 
        Disc=[Disc,BoundaryPoints(IndexBestCut)];
        %对左右两边的区间分别调用该子函数，得到各自的二划分点
        BinCut(BoundaryPoints,L_index,IndexBestCut,X,Ambiguous_label,Label_Mass,Num_Initial);
        BinCut(BoundaryPoints,IndexBestCut,R_index,X,Ambiguous_label,Label_Mass,Num_Initial);
%     else
%         if R_index-L_index-1==Num_Initial  %如果是第一个划分点的话保留
%             Disc=BoundaryPoints(IndexBestCut);
%         end
    end
end

end






