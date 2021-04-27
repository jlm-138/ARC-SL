%�Ӻ������Բ������ݷ���,����������Ӳ��ǩ
%���룺TestData-ĳһ���������ݣ�1*(P+1)��������P-������Ŀ
%      Classifier_rules--�������еĹ��������ǹ�����Ŀ��������P+3
%      Classifier_default--Ĭ���ࣨ��������ʾ����е���һ����
%      Class_set--1*M��Ԫ��ÿ����Ԫ�洢��һ�����ܵ���
%      K--1*P������,ÿ�������µ�ģ�����ֵ����Ŀ������������ı߽�㣻
%      PointSets--cell(1,P)��ÿ����Ԫ��һ�����������洢��ÿ�������µĻ��ֵ㣬ά����K(i)��С��ͬ
%      Num_class-ԭʼ�����е�������Ŀ
%      Decision_criterion:��ʾ�ж�������߻���Ӳ���ߣ� 1--Ӳ���ߣ� 0--�����
%      TK--��������Ҫ���ںϵĹ�����Ŀ
%�����Result--�ò������ݵ���𣬵�����ֵ��True--������ȷʱΪ1������Ϊ0��

% 2020.7.25--����֤�ݿ���µ�D-S���������࣬TopK�����ںϱ�����Ĺ���
%8.3--�������bug:�������ǩ����������������ɼ������ݼ���û��ĳ����𣩣�����ִ���---�����ݼ���Ԥ����


function [Result,True]=Classification(TestData,Classifier_rules,Classifier_default,Class_set,K,PointSets,TK,Num_class)

%���ж��ǲ���ѧ���˹���
n=size(Classifier_rules,1);
if n>0
    P=length(TestData)-1; %������������Ŀ
    %�Բ������ݵ�����ֵ��ģ������
    A=cell(P,1);  %����TestDataÿ������ֵ����Ӧģ�������µĵ�������ֵ
    for i=1:P
        %A{i,1}=zeros(1,K(i));
        for j=1:K(i)
            A{i,1}=Membership(TestData(1,i+1),K(i),PointSets{i}); %����ط���û�л���0.5cut��
            A{i,1}(find(A{i,1}<0.5))=0;
            %A{i,1}(find(A{i,1}>=0.5))=1;
        end
    end
    
    %��������������ÿһ���������ļ���ȴ�С
    if n<TK %����������еĹ�����ĿС��TK
        TK=n;
    end
    
    d=zeros(1,n);  %�洢ÿ�������Ӧ�ļ����
    for i=1:n
        Location_attr=find(Classifier_rules(i,1:P)); %��Щλ�õ�����ֵ��Ϊ0
        Num_attr=length(Location_attr);
        Activated_degree_vector=zeros(1,Num_attr);  %�洢����������������Ĺ�����ÿ��ǰ�������µļ���ȵ�ֵ
        for j=1:Num_attr
            Activated_degree_vector(1,j)=A{Location_attr(j),1}(1,Classifier_rules(i,Location_attr(j)));
            if Activated_degree_vector(1,j)==0
                break
            end
        end
        d(1,i)=(prod(Activated_degree_vector))^(1/Num_attr);
    end
    
    if d==0 %��ʾ��������û�м����κι��򣬰���Ĭ��������
        Result=str2double(Class_set{1,Classifier_default}); %�����ĳ���࣬������1�ͱ�ʾ�����w1��Ҳ��������������ʽ������޷��ж�����һ�����ʱ��
    else
        %��ȡTOP K����--Fused_rules(�п���ǰTK������û�б�ȫ������)
        [dd,Order]=sort(d,'descend');
        if min(dd(1,1:TK))>0  %�ж����Ƿ��ܹ�����ǰTK�������ֵ��Ӧ�Ĺ���
            Fused_rules=Classifier_rules(Order(1:TK),:);
        else
            Num_activated=length(find(dd));
            Fused_rules=Classifier_rules(Order(1:Num_activated),:);
        end
        
        %�洢Fused_rules�����Ӧÿ��������ۿ�����factor�������*�������Ŷȣ�
        Num_fused=size(Fused_rules,1);
        alpha=zeros(1,Num_fused);
        for i=1:Num_fused
            alpha(i)=Fused_rules(i,P+3)*dd(i);
        end
        
        %�洢ÿ������Ľ�Ԫ�ض�Ӧ��ͬ���򼯵����ӣ���Ӧ��massֵ��--Category_rule_factors
        Index_class=unique(Fused_rules(:,P+1)); %��Ҫ�ںϵĹ����еĻ������
        f=length(Index_class);
        Category_rule_factors=cell(1,f); %�洢ÿ�ֽ�Ԫ���¶�Ӧ���򼯵��ۿ����Ӵ�С
        ff=zeros(1,f); %��¼��Index_class��ÿ����Ԫ���µĹ�����Ŀ
        for i=1:f
            for j=1:Num_fused
                if Fused_rules(j,P+1)==Index_class(i,1)
                    ff(1,i)=ff(1,i)+1;
                    Category_rule_factors{1,i}(ff(1,i),1)=alpha(j);
                end
            end
        end
        
        %���Fused_rules�����й����Ӧ��mass��������ÿ�����콹Ԫ�أ���𣩵�Massֵ������һ����
        Mass_unormalized=zeros(1,f+1); %ǰf��λ�÷ֱ�洢Index_class��ǰf����Ԫ�ص�massֵ
        Mass_unormalized(1,f+1)=prod(1-alpha);%�����δ֪������
        for s=1:f
            %��һ�ֽ�Ԫ�������ʽ��ff(s)��mass����ȡ��Ԫ��f_s�������mass����ȡ������ʶ���(S1)
            S11=prod(Category_rule_factors{1,s});
            Temple_vector1=zeros(1,f);
            Temple_vector1(1,s)=1;
            for j=1:f
                if j~=s
                    Temple_vector1(1,j)=prod(ones(ff(j),1)-Category_rule_factors{1,j});
                end
            end
            S12=prod(Temple_vector1);
            S1=S11*S12;
            %�ڶ��ֽ�Ԫ�������ʽ����Ԫ����s��mass��������һ��ȡ�ý�Ԫ�أ���������mass������ȡ������ʶ���
            S2=0;
            for j=1:ff(s)
                Temple_vector2=zeros(1,f);
                Temple_vector2(1,s)=prod(Category_rule_factors{1,s})/Category_rule_factors{1,s}(j,1);
                for k=1:f
                    if k~=s
                        Temple_vector2(1,k)=prod(Category_rule_factors{1,k});
                    end
                end
                S2=S2+prod(Temple_vector2);
            end
            Mass_unormalized(1,s)=S1+S2;
        end
        Mass=Mass_unormalized/sum(Mass_unormalized);  %�洢��һ�����mass�ֲ�
        
        %if Decsion_criterion==1
        %�����Ӻ�������Mass����ת��Ϊ��������µ�pignistic���ʣ���������ֵ�������
        Focal_elements=cell(1,f);
        for i=1:f
            Focal_elements{1,i}=Class_set{1,Index_class(i)};
        end
        Pignistic_values=Pignistic(Focal_elements,Mass(1:f),Mass(f+1),Num_class);
        Result=[];
        %��ȡ���pignisticֵ��Ӧ����������
        for i=1:Num_class
            if Pignistic_values(1,i)==max(Pignistic_values)
                Result=[Result,i];
            end
        end
    end
else
    %�����������û�й��򣬾�ֱ�ӷ����Ĭ����
    Result=str2double(Class_set{1,Classifier_default});
end
    
    %�ж��Ƿ������ȷ��--���������ж�����ֻҪ������һ�����һ�£�����Ϊ������ȷ
    if ismember(TestData(1,1),Result)==1
        True=1;
    else
        True=0;
    end
    
end






