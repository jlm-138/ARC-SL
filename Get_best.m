%�Ӻ�������L_index+1��R_index-1�����ܵı߽����Ѱ������С�Ļ��ֵ�
%Revised by JLM on 2020-05-26
function [IndexBestCut,Index_left,Index_right,EntS1,EntS2,EntS,Entropy_min,L1,L2]=Get_best(BoundaryPoints,L_index,R_index,X,Label_Mass,Num_Initial)

Num_boundary=R_index-L_index-1;
Index_left=cell(Num_boundary,1); %�洢��ÿ���߽����ߵ���������λ��
Index_right=cell(Num_boundary,1); %�ڱ߽���ұߵ���������λ��
EntS1=zeros(Num_boundary,1); %ÿ���߽������Ӧ����������ֵ
EntS2=zeros(Num_boundary,1); %ÿ���߽���Ҳ��Ӧ����������ֵ
Entropy=zeros(Num_boundary,1); %�����洢E��A,T;S��
L1=zeros(Num_boundary,1);
L2=zeros(Num_boundary,1);

for i=L_index+1:R_index-1
    %�ȱ�ʾ��������ֵ��Ӧ�ı߽��֮�������ֵ���ݶ�Ӧ��λ��
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
    
    %���Ե�i���߽��Ϊ�и�����ֵ
    EntS1(i-L_index,1)=Entropy_interval(Index_left{i-L_index,1},Label_Mass); %�����Ӻ��������i���߽��������ݵ���ֵ
    EntS2(i-L_index,1)=Entropy_interval(Index_right{i-L_index,1},Label_Mass); %���i���߽���ұ����ݵ���ֵ
    
    %���Ե�i���߽��Ϊ�и�����ֵ������Pignistic��
%     EntS1(i-L_index,1)=Entropy_interval_pignistic(Index_left{i-L_index,1},Label_Mass); %�����Ӻ��������i���߽��������ݵ���ֵ
%     EntS2(i-L_index,1)=Entropy_interval_pignistic(Index_right{i-L_index,1},Label_Mass); %���i���߽���ұ����ݵ���ֵ
    
    %����Ե�i���߽�����������ֵ�����ж����������ֵ
    L1(i-L_index,1)=length(Index_left{i-L_index,1}); %�ڱ߽����ߵ�������Ŀ
    L2(i-L_index,1)=length(Index_right{i-L_index,1}); %�ڱ߽���ұߵ�������Ŀ
    N=L1(i-L_index,1)+L2(i-L_index,1);
    Entropy(i-L_index,1)=L1(i-L_index,1)*EntS1(i-L_index,1)/N+L2(i-L_index,1)*EntS2(i-L_index,1)/N;
end
Index_all=[Index_left{1,1};Index_right{1,1}];%��ʾ�����ǵ����������е�������������ֵ��Ӧ������
EntS=Entropy_interval(Index_all,Label_Mass); %��ʾ����Entropy(S)
% EntS=Entropy_interval_pignistic(Index_all,Label_Mass); %��ʾ����Entropy(S)������Pignistic��
[Entropy_min,Index]=min(Entropy);
IndexBestCut = Index + L_index;  
end

