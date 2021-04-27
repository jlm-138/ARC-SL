%�Ӻ�������L_index+1��R_index-1�����ܵı߽����Ѱ�����е���ɢ�㼯���ݹ麯��
%���룺BoundaryPoints--�߽�㴦������ֵ��
%      L_index-- ����߽߱�������ֵ���������0ʱ����ʾ�ڵ�һ���߽����������
%      R_index--���ұ߽߱�������ֵ���������1ʱ����ʾ�����һ���߽���Ҳ������
%      Num--��ʾ����ʼ�ı߽����Ŀ��Ѱ�ҵ�һ�������ֵ��ʱ���Ӧ�ı߽�����Ŀ��
%�����Disc--���յĶ�������ɢ�㼯��
%Revised by JLM on 2020-05-26
function BinCut(BoundaryPoints,L_index,R_index,X,Ambiguous_label,Label_Mass,Num_Initial)

global Disc

if  R_index-L_index>1
    %�����Ӻ����õ����Ż��ֵ��Ӧ������λ��
    [IndexBestCut,Index_left,Index_right,EntS1,EntS2,EntS,Entropy_min,L1,L2]=Get_best(BoundaryPoints,L_index,R_index,X,Label_Mass,Num_Initial);
    Index_left_min=Index_left{IndexBestCut-L_index,1};
    Index_right_min=Index_right{IndexBestCut-L_index,1};
    EntS1_min=EntS1(IndexBestCut-L_index,1);
    EntS2_min=EntS2(IndexBestCut-L_index,1);
    L1_min=L1(IndexBestCut-L_index,1); %�����õ��ı߽����ߵ�������
    L2_min=L2(IndexBestCut-L_index,1); %�����õ��ı߽����ߵ�������
    N=L1_min+L2_min; %�������۵ļ����е�������
    
    %�����Ӻ������ж���һ�����õ�����ɢ���ǲ��ǽ���
    [flag,MDLP]=MDLP_Accepted(Index_left_min,Index_right_min,EntS1_min,EntS2_min,EntS,Entropy_min,N,Ambiguous_label,Label_Mass);
    
    if flag==1 
        Disc=[Disc,BoundaryPoints(IndexBestCut)];
        %���������ߵ�����ֱ���ø��Ӻ������õ����ԵĶ����ֵ�
        BinCut(BoundaryPoints,L_index,IndexBestCut,X,Ambiguous_label,Label_Mass,Num_Initial);
        BinCut(BoundaryPoints,IndexBestCut,R_index,X,Ambiguous_label,Label_Mass,Num_Initial);
%     else
%         if R_index-L_index-1==Num_Initial  %����ǵ�һ�����ֵ�Ļ�����
%             Disc=BoundaryPoints(IndexBestCut);
%         end
    end
end

end






