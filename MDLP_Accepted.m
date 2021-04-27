% 子函数：判断所求得的最优划分点是不是被接受
% 接受-flag=1;不接受-flag=0
%Revised by JLM on 2020-05-26
function [flag,MDLP]=MDLP_Accepted(Index_left_min,Index_right_min,EntS1_min,EntS2_min,EntS,Entropy_min,N,Ambiguous_label,Label_Mass)

flag=0; %初始化为0

%统计在最小熵值点处对应的边界点的左右两侧的样本类别数
Num1=Num_class(Index_left_min,Ambiguous_label,Label_Mass); %左侧
Num2=Num_class(Index_right_min,Ambiguous_label,Label_Mass); %右侧
Num=Num_class([Index_left_min; Index_right_min],Ambiguous_label,Label_Mass); %所有  

D_value=log2(3^Num-2)-(Num*EntS-Num1*EntS1_min-Num2*EntS2_min);

%基于最小描述长度准则，给出判断式MDLP
Gain=EntS-Entropy_min;
MDLP=Gain-(log2(N-1)+D_value)/N;
if MDLP>0
    flag=1;
end

end

