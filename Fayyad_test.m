%�Ӻ�����Fayyad��ɢ��
%���룺X-ѵ����������ֵ���ϣ���������
%      Ambiguous_label-��Ӧÿ�����������ǩ���а�Ԫ
%      Label_Mass--cell(N*2)����һ�д洢��Ԫ�أ��ڶ��д洢��Ӧ�ý�Ԫ�ص�massֵ
%����������Ե����зָ�㼯���洢Ϊ������

function Disc_Out=Fayyad_test(X,Ambiguous_label,Label_Mass)
global Disc
Disc = [];
%��һ��������Ӧmass������ͬ�������ĵ������ֵ���е���Ϊ�߽��
 S=unique(sort(X)); %��X�����ȥ����ͬ������ֵ
 m=length(S); %��ʾ��������ֵ����Ŀ
 BoundaryPoints=[];
 Index_judge=zeros(m,1); %���������ж�S��ÿ������ֵ��Ӧ�����������ǩ�ǲ���һ����1-��ͬ��0-��ͬ��
 for i=1:m
     Index_attri=find(X==S(i));  % S�е�i������ֵ��ӦX�е��ĸ�������Щλ�ô�������ֵ��
     Num=length(Index_attri);  %������ֵ��Ӧ�������ǲ���Ψһ�ģ�
     if Num==1
        Index_judge(i,1)=1;
     else
         %��һ������ֵ��Ӧ�������ʱ���ж������ǩ�ǲ���һ��
         flag1=0;
         for j=1:Num-1 
             for k=j+1:Num
                 if isequal(Label_Mass{Index_attri(j),1},Label_Mass{Index_attri(k),1})==0 || isequal(Label_Mass{Index_attri(j),2},Label_Mass{Index_attri(k),2})==0
                    Index_judge(i,1)=0;
                    flag1=1;
                    break
                 end
             end
             if flag1==1
                 break
             end
         end
         if flag1==0
             Index_judge(i,1)=1;
         end
     end     
 end
 for i=1:m-1
     if Index_judge(i)==0 %��˵��Ӧ��ͬ��������
         BoundaryPoints=[BoundaryPoints,(S(i)+S(i+1))/2];
     else if Index_judge(i+1)==0 %��˵��Ӧһ������Ҷ˵��Ӧ��ͬ��������
             BoundaryPoints=[BoundaryPoints,(S(i)+S(i+1))/2];
         else
             %���Ҷ˵�ֱ��Ӧһ�����(���ܴ��ڶ��������Ӧһ������ֵ�����)���Ƚ�����������ǲ���һ����
             Index_attri_1=find(X==S(i));
             Index_attri_2=find(X==S(i+1));
             if isequal(Label_Mass{Index_attri_1(1),1},Label_Mass{Index_attri_2(1),1})==0 || isequal(Label_Mass{Index_attri_1(1),2},Label_Mass{Index_attri_2(1),2})==0
                 BoundaryPoints=[BoundaryPoints,(S(i)+S(i+1))/2];
             end
         end
     end
 end
 
 
 %����һ�ַ����������еĵ㶼�����߽��
%  BoundaryPoints=zeros(1,m-1);
%  for i=1:m-1
%      BoundaryPoints(1,i)=(S(i)+S(i+1))/2;
%  end
 
 %�ڶ������ӱ߽����Ѱ�����ŵĶ��ָ��
Num_Initial=length(BoundaryPoints);
L_index=0;  %���߽����������ָ��Ϊ����ֵΪ0
R_index=Num_Initial+1; %���߽���Ҳ������ָ��Ϊ����ֵB+1
BinCut(BoundaryPoints,L_index,R_index,X,Ambiguous_label,Label_Mass,Num_Initial); %�ӵ�L_index���߽�㵽��R_index��Ѱ�����ŵĶ��ָ��
Disc_Out=sort(Disc); %�õ�������������С�����ֵ�ķָ�㼯�ϣ��洢Ϊ������
 
 