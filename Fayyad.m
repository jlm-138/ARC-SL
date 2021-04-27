%子函数：Fayyad离散化
%输入：X-训练样本属性值集合，列向量；
%      Ambiguous_label-对应每个样本的软标签，列胞元
%      Label_Mass--cell(N*2)，第一列存储焦元素，第二列存储对应该焦元素的mass值
%输出：该属性的所有分割点集，存储为行向量

function Disc_Out=Fayyad(X,Ambiguous_label,Label_Mass)
global Disc
Disc = [];
%第一步：根据样本属性值及其类别确定边界点集，存储为列向量
 BoundaryPoints=[];
 S=unique(sort(X)); %将X排序后去掉相同的属性值
 m=length(S); %表示互异属性值的数目
 Index_class=zeros(m,1); %列向量：判断S中每个属性值对应的样本是不是同一种类别（1-同一种，0-不同种类别）
 for i=1:m
     Index_attri=find(X==S(i));  % S中第i个属性值对应X中的哪个或者哪些位置处的属性值？
     Num=length(Index_attri);  %该属性值对应的样本是不是唯一的？
     if Num==1
        Index_class(i,1)=1;
     else
         %当一个属性值对应多个样本时，判断其对应的是不是同一种类别？
         flag1=0;
         for j=1:Num-1 
             for k=j+1:Num
                 if isequal(Ambiguous_label{Index_attri(j)},Ambiguous_label{Index_attri(k)})==0
                    Index_class(i,1)=0;
                    flag1=1;
                    break
                 end
             end
             if flag1==1
                 break
             end
         end
         if flag1==0
             Index_class(i,1)=1;
         end
     end     
 end
 for i=1:m-1
     if Index_class(i)==0 %左端点对应不同类别的样本
         BoundaryPoints=[BoundaryPoints,(S(i)+S(i+1))/2];
     else if Index_class(i+1)==0 %左端点对应一种类别，右端点对应不同类别的样本
             BoundaryPoints=[BoundaryPoints,(S(i)+S(i+1))/2];
         else
             %左右端点分别对应一种类别(可能存在多个样本对应一个属性值的情况)，比较这两种类别是不是一样？
             Index_attri_1=find(X==S(i));
             Index_attri_2=find(X==S(i+1));
             if isequal(Ambiguous_label{Index_attri_1(1)},Ambiguous_label{Index_attri_2(1)})==0
                 BoundaryPoints=[BoundaryPoints,(S(i)+S(i+1))/2];
             end
         end
     end
 end
 
 %第二步：从边界点中寻找最优的二分割点
Num_Initial=length(BoundaryPoints);
L_index=0;  %将边界点左侧的数据指定为索引值为0
R_index=Num_Initial+1; %将边界点右侧的数据指定为索引值B+1
BinCut(BoundaryPoints,L_index,R_index,X,Ambiguous_label,Label_Mass,Num_Initial); %从第L_index个边界点到第R_index中寻找最优的二分割点
Disc_Out=sort(Disc); %得到不包含属性最小和最大值的分割点集合，存储为行向量
 
 