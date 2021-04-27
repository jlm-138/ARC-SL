%input:F(k)
%outpt:F(k+1); F(k+1)��ÿ�����Ӧ��֧�ֶȣ� L: F(k+1)�к��е�Ƶ����ĸ���

function [EF2,sup,L]=Apriori_gen(EF1,k,P,AT,min_sup)

EF2=[];
sup=[];
L=0; % EF2��Ƶ����ĸ���

%N=size(TrainingData,1);
m=size(EF1,1);
if m>1
    if k==1   %��1��2���
        for i1=1:m-1
            for i2=(i1+1):m
                location_1=find(EF1(i1,1:P)); %Ѱ��EF1�е�i1���Ӧ��һ��ģ������
                location_2=find(EF1(i2,1:P));
                if location_1<location_2  %��ģ�������ǲ�ͬ�����µ�
                    C=zeros(1,P); %�洢ÿһ�ֿ��ܵ���Ϻ��ǰ����
                    C(1,location_1)=EF1(i1,location_1);
                    C(1,location_2)=EF1(i2,location_2);
                    sup2_item=sup_item(C,AT); 
                    if sup2_item>=min_sup
                        L=L+1;
                        EF2(L,:)=C;
                        sup(L,1)=sup2_item;
                    end
                end
            end
        end  
    else 
        for j1=1:m-1   %EF�еĵ�j1��
            for j2=(j1+1):m  %EF�еĵ�j2��
                %combination 
                vector_location_1=find(EF1(j1,1:P)); %Ѱ��EF_k�е�j1���Ӧ�ļ���ģ������ĳ˻�
                vector_location_2=find(EF1(j2,1:P));
                if vector_location_1(1,1:k-1)==vector_location_2(1,1:k-1) & vector_location_1(1,k)<vector_location_2(1,k)
                    if EF1(j1,vector_location_1(1,1:k-1))==EF1(j2,vector_location_2(1,1:k-1))
                        C=zeros(1,P);
                        C(1,vector_location_1(1,1:k-1))=EF1(j1,vector_location_1(1,1:k-1));
                        C(1,vector_location_1(1,k))=EF1(j1,vector_location_1(1,k));
                        C(1,vector_location_2(1,k))=EF1(j2,vector_location_2(1,k));
                        
                        %����һ��ȥ��pruning����
                        sup2_item=sup_item(C,AT);
                        if sup2_item>=min_sup
                            L=L+1;
                            EF2(L,:)=C;
                            sup(L,1)=sup2_item;
                        end
                        
                        %��������pruning+support computing 
%                         location=[vector_location_1(1,1:k) vector_location_2(1,k)]; %��ʾ����Ϻ��ģ������ķ���Ԫ��λ��
%                         subset=zeros(k+1,P);  %�����е��Ӽ�����洢Ϊ�������ʽ��������ʾ��k+1���Ӽ��������Ŀ
%                         for s=1:k+1
%                             subset(s,1:P)=C;
%                             subset(s,location(1,s))=0;  %��C�еĵ�s��Ԫ���滻0��������ͬ
%                         end
%                         logical_value=ismember(subset,EF1,'rows'); %�õ�һ���߼�ֵ���������ж����Ӽ��ǲ���Ƶ��k-ruleitems��ǰ����
%                         if logical_value==ones(k+1,1)  %���C�������Ӽ�����Ƶ����
%                             sup2_item=sup_item(C,AT);
%                             if sup2_item>=min_sup
%                                 L=L+1;
%                                 EF2(L,:)=C;
%                                 sup(L,1)=sup2_item;
%                             end
%                         end
                    end
                end
            end
        end
    end
end
%��Ͻ���
end 
                            

        
        
        
        
   
    








