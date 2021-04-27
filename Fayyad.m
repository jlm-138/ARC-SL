%�Ӻ�����Fayyad��ɢ��
%���룺X-ѵ����������ֵ���ϣ���������
%      Ambiguous_label-��Ӧÿ�����������ǩ���а�Ԫ
%      Label_Mass--cell(N*2)����һ�д洢��Ԫ�أ��ڶ��д洢��Ӧ�ý�Ԫ�ص�massֵ
%����������Ե����зָ�㼯���洢Ϊ������

function Disc_Out=Fayyad(X,Ambiguous_label,Label_Mass)
global Disc
Disc = [];
%��һ����������������ֵ�������ȷ���߽�㼯���洢Ϊ������
 BoundaryPoints=[];
 S=unique(sort(X)); %��X�����ȥ����ͬ������ֵ
 m=length(S); %��ʾ��������ֵ����Ŀ
 Index_class=zeros(m,1); %���������ж�S��ÿ������ֵ��Ӧ�������ǲ���ͬһ�����1-ͬһ�֣�0-��ͬ�����
 for i=1:m
     Index_attri=find(X==S(i));  % S�е�i������ֵ��ӦX�е��ĸ�������Щλ�ô�������ֵ��
     Num=length(Index_attri);  %������ֵ��Ӧ�������ǲ���Ψһ�ģ�
     if Num==1
        Index_class(i,1)=1;
     else
         %��һ������ֵ��Ӧ�������ʱ���ж����Ӧ���ǲ���ͬһ�����
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
     if Index_class(i)==0 %��˵��Ӧ��ͬ��������
         BoundaryPoints=[BoundaryPoints,(S(i)+S(i+1))/2];
     else if Index_class(i+1)==0 %��˵��Ӧһ������Ҷ˵��Ӧ��ͬ��������
             BoundaryPoints=[BoundaryPoints,(S(i)+S(i+1))/2];
         else
             %���Ҷ˵�ֱ��Ӧһ�����(���ܴ��ڶ��������Ӧһ������ֵ�����)���Ƚ�����������ǲ���һ����
             Index_attri_1=find(X==S(i));
             Index_attri_2=find(X==S(i+1));
             if isequal(Ambiguous_label{Index_attri_1(1)},Ambiguous_label{Index_attri_2(1)})==0
                 BoundaryPoints=[BoundaryPoints,(S(i)+S(i+1))/2];
             end
         end
     end
 end
 
 %�ڶ������ӱ߽����Ѱ�����ŵĶ��ָ��
Num_Initial=length(BoundaryPoints);
L_index=0;  %���߽����������ָ��Ϊ����ֵΪ0
R_index=Num_Initial+1; %���߽���Ҳ������ָ��Ϊ����ֵB+1
BinCut(BoundaryPoints,L_index,R_index,X,Ambiguous_label,Label_Mass,Num_Initial); %�ӵ�L_index���߽�㵽��R_index��Ѱ�����ŵĶ��ָ��
Disc_Out=sort(Disc); %�õ�������������С�����ֵ�ķָ�㼯�ϣ��洢Ϊ������
 
 