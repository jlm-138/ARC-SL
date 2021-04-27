%�Ӻ���������Apriori��˼�룬�Ӻ���k��ģ�������Ƶ����������ϵõ�����k+1��ģ�������Ƶ��������Ĺ���
%���룺k-����Ƶ����������ģ��ǰ�����Ŀ��
%      F1-���е�Ƶ��������,�洢Ϊ������Ƶ�������Ŀ��������P+1�ľ���
%      P-���������Ե���Ŀ�� Mu-ѵ����������ֵ��ÿ��ģ�������µ�������ֵ��cell(1,N)
%      Label_mass-ָ����ѵ��������Ӧ�����ǩ���ֱ�洢��Ӧ�Ľ�Ԫ���Լ�massֵ��cell(N,2)
%���: F2-Ƶ��������,�洢��ʽ��FreqRuleitems_initial���ƣ�
%      Sup_ruleitems-Ƶ���������֧�ֶȣ���������������FreqRuleitemsһ��
%      Conf_ruleitems--��Ӧ��������Ŷȣ�������
%7.29- 46����90�м���֧�ֶȣ�û�а����޸Ĺ����Ĺ�ʽ����-�Ծ�ȷ�����û��Ӱ��

function [F2,Sup_ruleitems,Conf_ruleitems,Num2]=CandidateGen(k,F1,P,Mu,Class_set,Label_mass,minsup,Num_class)

N=length(Mu);    %��ʾѵ����������Ŀ
Num1=size(F1,1); %��ʾF1��Ƶ�������Ŀ
Num2=0; %��¼F2��Ƶ����ĸ���
F2=[];
Sup_ruleitems=[];
Conf_ruleitems=[];

if Num1>1
    Class_index=unique(F1(:,P+1));
    m=length(Class_index);  %F1�е�Ƶ���������Ӧ����Ľ�������ж����֣�

    if k==1 %��1-ruleitem��2-ruleitem,�������ͬ�Ľ������
        %�Ƚ�������
        for s=1:m
            f1=F1(F1(:,P+1)==s,:); 
            n=size(f1,1);
            for i=1:n-1
                for j=i+1:n
                    Location1=find(f1(i,1:P));
                    Location2=find(f1(j,1:P));
                    if Location1< Location2
                       C1=zeros(1,P+1);
                       C1(P+1)=s;
                       C1(1,Location1)=f1(i,Location1);
                       C1(1,Location2)=f1(j,Location2);
                       
                       %����ruleitem C1��֧�ֶ�
                        [Sup_A,Sup]=Support_Ruleitem(C1(1,1:P),Mu,Class_set,s,Label_mass);
                       
                       c1=Num_class(1,s)/max(Num_class);  %��������Ӧ��ֵϵ��
                       if Sup>=minsup*c1
                       %if Sup>=minsup    
                           Num2=Num2+1;
                           F2(Num2,:)=C1;
                           Sup_ruleitems(Num2,1)=Sup;
                           Conf_ruleitems(Num2,1)=Sup/Sup_A;
                       end
                    end
                end
            end
        end
    else
        %���濼�ǳ�ʼ�Ĺ�������Ŀ���ڵ���2ʱ������Aprioriԭ����ϵ����
        for s=1:m
            ff1=F1(find(F1(:,P+1)==s),:); %��Ӧ�����s��Ƶ��������
            nn=size(ff1,1);
            for i=1:nn-1   %EF�еĵ�j1��
                for j=(i+1):nn
                    %combination
                    Vector_location1=find(ff1(i,1:P));
                    Vector_location2=find(ff1(j,1:P));
                    if Vector_location1(1,1:k-1)==Vector_location2(1,1:k-1) & Vector_location1(1,k)< Vector_location2(1,k)
                        if ff1(i,Vector_location1(1,1:k-1))==ff1(j,Vector_location2(1,1:k-1))
                            C2=zeros(1,P+1);
                            C2(1,Vector_location1(1,1:k-1))=ff1(i,Vector_location1(1,1:k-1));
                            C2(1,Vector_location1(1,k))=ff1(i,Vector_location1(1,k));
                            C2(1,Vector_location2(1,k))=ff1(j,Vector_location2(1,k));
                            C2(1,P+1)=s;
                            
                            %���������C2��֧�ֶ�
                            [Sup_AA,Sup]=Support_Ruleitem(C2(1,1:P),Mu,Class_set,s,Label_mass);
                            c2=Num_class(1,s)/max(Num_class); 
                            if Sup>=minsup*c2
                            %if Sup>=minsup
                                Num2=Num2+1;
                                F2(Num2,:)=C2;
                                Sup_ruleitems(Num2,1)=Sup;
                                Conf_ruleitems(Num2,1)=Sup/Sup_AA;
                            end
                        end
                    end
                end
            end
        end
    end
end
        
            
                           
                           
                          
                           
                           
                       
                       
                    
            
        
        
        
        
        
        
        
        

