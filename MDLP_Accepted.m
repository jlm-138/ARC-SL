% �Ӻ������ж�����õ����Ż��ֵ��ǲ��Ǳ�����
% ����-flag=1;������-flag=0
%Revised by JLM on 2020-05-26
function [flag,MDLP]=MDLP_Accepted(Index_left_min,Index_right_min,EntS1_min,EntS2_min,EntS,Entropy_min,N,Ambiguous_label,Label_Mass)

flag=0; %��ʼ��Ϊ0

%ͳ������С��ֵ�㴦��Ӧ�ı߽���������������������
Num1=Num_class(Index_left_min,Ambiguous_label,Label_Mass); %���
Num2=Num_class(Index_right_min,Ambiguous_label,Label_Mass); %�Ҳ�
Num=Num_class([Index_left_min; Index_right_min],Ambiguous_label,Label_Mass); %����  

D_value=log2(3^Num-2)-(Num*EntS-Num1*EntS1_min-Num2*EntS2_min);

%������С��������׼�򣬸����ж�ʽMDLP
Gain=EntS-Entropy_min;
MDLP=Gain-(log2(N-1)+D_value)/N;
if MDLP>0
    flag=1;
end

end

