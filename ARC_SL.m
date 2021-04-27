% ARC_SL: Association rule-based classification with soft labels
% Copyright (C) 2021-2022, by Lianmeng Jiao (jiaolianmeng@nwpu.edu.cn)

function [Test_Classification_result,Test_True_rate,Classifier_rules,Class_set,Classifier_rule_number,Total_rule_number,Train_time,Test_time]=ARC_SL(TrainingData,TestData,Label_mass,N1,N2,Num_class_original)

tic
P=size(TrainingData,2)-1; %���Ը���

%�����ɵ��ڵĲ���
minsup=0.01; 
minconf=0.5; 
Max_fre_ruleitem=20000; %��Ƶ������������һ���������ֵ

%% ��һ��������Fayyad��ɢ���������������Խ���ģ������

%�Ƚ�ÿ��ѵ������������������ǩ����Ϊ����������ʶ���֮���������Ԫ�ض�Ӧ�����mass�����ڼ�Mass,��Ϊ����Ԫ��
Ambiguous_label=cell(N1,1);
for j=1:N1
    Ambiguous_label{j}=Label_mass{j,1}; 
end

%��������������ǩ�Լ�����ֵ������Fayyad��ɢ��˼��õ��ָ�㼯
K=zeros(1,P); % ÿ�������µ�ģ��������
PointSets=cell(1,P); %ÿ�������µ��и�㼯����ͬ��С�Լ����ֵ��
%Attributes_judge=ones(1,P); %�ж������ǲ��Ǳ����������ǣ���������ɢ���ܲ��ܵõ���ɢ��
Num_disc=zeros(1,P); %�洢ÿ��ά���µ���ɢ����Ŀ
Disc=cell(1,P); %�洢ÿ��ά���¼����������ɢ�㼯��
%tic
for i=1:P
    X=TrainingData(:,i+1); %��ʾ��i�����Ե���������ֵ����
    a=min(X); %��˵�
    b=max(X); %�Ҷ˵�
    Disc{i}=Fayyad_test(X,Ambiguous_label,Label_mass);  %�����Ӻ������õ��ָ��ļ���,������
   %Disc=Fayyad(X,Ambiguous_label,Label_mass); 
%     Disc=FuzzyGrid(X,3);  %�����Ӻ������õ��ָ��ļ���,������(fuzzy grid)
   %�ҳ���Ӧ�����Ե�ģ�����ֵ�---PointSets{i}
    Num_disc(i)=length(Disc{i});  %��ѧ������ɢ�����Ŀ
    if Num_disc(i)==0
        %Attributes_judge(1,i)=0; 
        K(i)=0;
    else
        d=zeros(1,Num_disc(i)+1);  %�洢�����Ҷ˵��Լ���ɢ�����ָ������Num_disc(i)+1�����䳤��
        d(1)=Disc{i}(1)-a;
        d(Num_disc(i)+1)=b-Disc{i}(Num_disc(i));
        for j=2:Num_disc(i)
            d(j)=Disc{i}(j)-Disc{i}(j-1);
        end
        [dd,Index_min]=min(d);
        %��ÿ����ɢ�������������Ϊdd/2�ĵ㣬ÿ����ɢ������඼�ܵõ����ֵ�
        PointSets{i}=zeros(1,2*Num_disc(i));
        for j=1:Num_disc(i)
            PointSets{i}(1,2*j-1)=Disc{i}(j)-dd/2;
            PointSets{i}(1,2*j)=Disc{i}(j)+dd/2;
        end
        %�õ��Ļ��ֵ��п��ܻ����ĳ��������ȵ���������غϣ���˵����Ӧ�����䳤����������С��
    end
    K(i)=length(PointSets{i}); %�������µ�ģ�����ֵ���������ɢ����Ŀ�Ķ���
end
%time_discret=toc; %��¼����ɢ����ʱ��

%�����������õ���ģ�����ֵ㼯��������ģ�����֣���ÿ��ѵ����������ģ��������ֵ
Mu=cell(1,N1);
for j=1:N1
    Mu{1,j}=cell(P,1);
    for i=1:P
        if Num_disc(i)>0  %��������ɢ������Զ�Ӧ��ģ������
           Mu{1,j}{i,1}=Membership(TrainingData(j,i+1),K(i),PointSets{i}); 
           Mu{1,j}{i,1}(find(Mu{1,j}{i,1}<0.5))=0; %��С��0.5�������Ƚص�
           %Mu{1,j}{i,1}(find(Mu{1,j}{i,1}>=0.5))=1; %��Ӧ����Ӳ���֣�Ϊ�˼������
        end
    end
end
   
%% �ڶ��������������������ģ�����֣�����Apriori�㷨�����ǩ�������������ھ����
%tic
%��ѵ�����������ǩ�г���������ʶ���֮���������Ԫ����Ϊ������𼯺�,�洢Ϊ�а�Ԫ
M=1; %ѵ�������С��������Ŀ
Class_set{1,1}=Label_mass{1,1};
for i=2:N1
    flag1=1;
    for j=1:i-1
        if isequal(Label_mass{i,1},Label_mass{j,1})==1
            flag1=0;
            break
        end
    end
    if flag1==1
        M=M+1;
        Class_set{1,M}=Label_mass{i,1};
    end
end

Freq_ruleitems=cell(1,P);  %�õ���ͬ������Ŀ�µ�Ƶ��������
Num_ruleitems=zeros(1,P); %��ʾ��ͬ������Ŀ��Ƶ�����������Ŀ
Sup_fre_ruleitems=cell(1,P); %�洢����ÿ��Ƶ���������Ӧ��֧�ֶ�
Conf_rules=cell(1,P); %�洢����ÿ��Ƶ���������Ӧ�����Ŷ�

Num_rules=zeros(1,P);  %��ʾ��ͬ������Ŀ�¹������Ŀ
Mined_rules=cell(1,P); 

%���ѵ������ÿ�������ֵĴ���
Num_class=zeros(1,M);
for s=1:M
    for i=1:N1
        %����һ��ֱ���������Mass����Ӧ�������Ϊ����������ǩ
%          if isequal(Label_mass{i,1},Class_set{1,s})==1  
%              Num_class(1,s)=Num_class(1,s)+1;
%          end
       %�����������������ǵ������ÿ�������е�massֵ
       if isequal(Label_mass{i,1},Class_set{1,s})==1
          Num_class(1,s)=Num_class(1,s)+Label_mass{i,2};
       end
    end
end

%�г����е�Ƶ��1-ruleitems����Ӧ���ֻ��һ��ģ������Ĺ���
Num_ruleitems(1,1)=0; 
Num_rules(1,1)=0; 
Freq_ruleitems{1,1}=[]; %�洢Ϊ����������Num_ruleitems(1,1)��������P+1��ǰP�������P+1���Ƕ�ӦClass_set�е�λ������
Sup_fre_ruleitems{1,1}=[]; %������,������ Num_ruleitems(1,1)
Conf_rules{1,1}=[]; %������,������ Num_rules(1,1)
Mined_rules{1,1}=[]; %���������ǹ�����Ŀ��������P+3,�����зֱ�Ϊ�������ֵ��֧�ֶȺ����Ŷȣ�ÿһ�д���һ������
for i=1:P
    if Num_disc(i)>0
    Item=zeros(1,P);
    for t=1:(Num_disc(i)+1)
        Item(1,i)=t;
        Sup_ruleitem=zeros(1,M); %�洢Item��Ӧ����Class_set{1,S}��֧�ֶ�
        Conf_temple=zeros(1,M);
        for s=1:M
           %�����Ӻ���Support_ruleitem:ͬʱ���ǰ����͹������֧�ֶ�
           [Sup_item,Sup_ruleitem(1,s)]=Support_Ruleitem(Item,Mu,Class_set,s,Label_mass); 
            c=Num_class(1,s)/max(Num_class);  %��ϵ����������������Ӧ��ֵ
            if Sup_ruleitem(1,s)>=minsup*c
            %if Sup_temple(1,s)>=minsup
                Num_ruleitems(1,1)=Num_ruleitems(1,1)+1;
                Freq_ruleitems{1,1}(Num_ruleitems(1,1),1:P)=Item;
                Freq_ruleitems{1,1}(Num_ruleitems(1,1),P+1)=s;
                Sup_fre_ruleitems{1,1}(Num_ruleitems(1,1),1)=Sup_ruleitem(1,s);
                
                %�������Ŷȵ�ֵ��������Ӧ����
                Conf_temple(1,s)=Sup_ruleitem(1,s)/Sup_item;
                if Conf_temple(1,s)>=minconf*c
                %if Conf_temple(1,s)>=minconf
                    Num_rules(1,1)=Num_rules(1,1)+1;
                    Conf_rules{1,1}(Num_rules(1,1),1)=Conf_temple(1,s);
                    Mined_rules{1,1}(Num_rules(1,1),1:P+1)=Freq_ruleitems{1,1}(Num_ruleitems(1,1),:); 
                    Mined_rules{1,1}(Num_rules(1,1),P+2)=Sup_ruleitem(1,s);
                    Mined_rules{1,1}(Num_rules(1,1),P+3)=Conf_temple(1,s);
                end
            end    
        end
    end
    end
end

%�����Ӻ���������Apriori�㷨��˼����ϵó�Ƶ��k-ruleitems
if Num_ruleitems(1,1)< Max_fre_ruleitem
    for k=1:P-1
        %tic
        [Freq_ruleitems{1,k+1},Sup_fre_ruleitems{1,k+1},Confidence,Num_ruleitems(1,k+1)]=CandidateGen(k,Freq_ruleitems{1,k},P,Mu,Class_set,Label_mass,minsup,Num_class);
        %time_frequent_mining=toc
        %����Ƶ�������ɹ���
        Num_rules(1,k+1)=0;
        Mined_rules{1,k+1}=[];
        for j=1:Num_ruleitems(1,k+1) %��j��Ƶ��(k+1��-�
             cc=Num_class(1,Freq_ruleitems{1,k+1}(j,P+1))/max(Num_class); 
            
           if Confidence(j,1)>=minconf*cc
           %if Confidence(j,1)>=minconf
              Num_rules(1,k+1)=Num_rules(1,k+1)+1; 
              Conf_rules{1,k+1}(Num_ruleitems(1,k+1),1)=Confidence(j,1);
              Mined_rules{1,k+1}(Num_rules(1,k+1),1:P+1)=Freq_ruleitems{1,k+1}(j,:);
              Mined_rules{1,k+1}(Num_rules(1,k+1),P+2)=Sup_fre_ruleitems{1,k+1}(j,:);
              Mined_rules{1,k+1}(Num_rules(1,k+1),P+3)=Confidence(j,1);
           end
        end
     
        %�ж�������û�г������ޣ�Ҫ��Ҫ�����ھ�Ƶ����
        if sum(Num_ruleitems(1,1:k+1))>= Max_fre_ruleitem
            disp('Up to the Fre_limits');
            break
        end %��ѧ����Ƶ�����������һ��������ֵ���Ͳ����ھ�Ƶ����
    end
end
Total_rule_number=sum(Num_rules); %��ʾ�ھ���ܵĹ�����Ŀ
%time_mining=toc; 

%% ��������Pruning from the mined rules for building the classifier

%tic  %���������еĵ�һ���������ʱ��ģ���Ϊ�ھ򵽵Ĺ�����Ŀ�϶�
%��1����Mined_rules��ȥ���������
% Using general and high confidence for deleting specific and low confidence rules
Delete_rules=Mined_rules;  %�洢��һ��������Ĺ��򼯣��洢��ʽ���ھ򵽵Ĺ���洢��ʽ��ͬ
Num_delete_rules=zeros(1,P); %Delete_Rules�У���ͬ������Ŀ��Ӧ�Ĺ�����Ŀ
%tic
for k=P:-1:2
    Delete_rows=[];   %ɾ��Mined_rules{1,k}����Щ�����Ĺ���
    Num_Delete_rows=0; 
    if Num_rules(1,k)~=0 & Num_rules(1,k-1)~=0 
        for i=1:Num_rules(1,k)  
            Ant_item=Mined_rules{1,k}(i,1:P); %����k��ǰ������ģ�����еĵ�i�������Ӧ��ǰ����
            for j=1:k   %��k���Ӽ������
                Subset_Ant_item=Ant_item;  %������
                Replace_location=find(Ant_item);  
                Subset_Ant_item(1,Replace_location(1,j))=0; %�õ�ԭ����ǰ�����һ���Ӽ�
                
                %��������õ��Ĺ����Ӽ��ǲ����ں���k-1��ǰ�����ԵĹ�����
                [Value,Index_row]=ismember(Subset_Ant_item,Mined_rules{1,k-1}(:,1:P),'rows');
                %Value���߼�ֵ����������ͬ�ģ��ͷ���1������Ϊ0��Index_rowΪ��������ǰ��������ͬ���У����һ�γ�����ͬ����һ�У�
                if Value==1
                    if Mined_rules{1,k}(i,P+3)<= Mined_rules{1,k-1}(Index_row,P+3) && Mined_rules{1,k}(i,P+1)== Mined_rules{1,k-1}(Index_row,P+1) %�������ͬ
                     %if Mined_rules{1,k}(i,P+3)<= Mined_rules{1,k-1}(Index_row,P+3) %�����ǹ������
                        Num_Delete_rows=Num_Delete_rows+1;
                        Delete_rows(1,Num_Delete_rows)=i;
                        break
                        %ֻҪ�����д���һ���������Ӽ����Ͳ��ٱ��������Ĺ����Ӽ����������ѭ����
                    end
                end
            end
        end
    end
    Delete_rules{1,k}(Delete_rows,:)=[]; %��ǰ��������Ŀ��k�Ĺ�����ȥ����Ӧ�����Ĺ���
    Num_delete_rules(1,k)=size(Delete_rules{1,k},1);
end
Num_delete_rules(1,1)=size(Delete_rules{1,1},1);
Num_after_deleting=sum(Num_delete_rules); %��ʾ������Ĺ�����Ŀ
%time1=toc

%��2���Թ����������
%����һ���õ��Ĺ���Delete_rules�������ͬ�洢�ڰ�Ԫ����Rule_sets�У����洢����ָ��
Rule_sets=cell(1,M); %ÿ����Ԫ�洢���Ǿ��в�ͬ����rules
Order1_index=cell(1,M); %���������ָ�꣬�ֱ�Ϊ���Ŷȣ�֧�ֶȺ͹������ɵ�˳��
nn=zeros(1,M);  %�洢ÿ������Ԫ�¶�Ӧ�Ĺ�����
%tic
for k=1:P
    for i=1:size(Delete_rules{1,k},1)
        for s=1:M
            if Delete_rules{1,k}(i,P+1)==s
                nn(s)=nn(s)+1;
                Rule_sets{1,s}(nn(s),:)=Delete_rules{1,k}(i,:);
                %���ǵ���������sortrowsֻ֧���������У��������ŶȺ�֧�ֶȱȽϵ�ʱ��ȡ��
                Order1_index{1,s}(nn(s),1)=-Delete_rules{1,k}(i,P+3); %���Ŷ�
                Order1_index{1,s}(nn(s),2)=-Delete_rules{1,k}(i,P+2); %֧�ֶ�
            end
        end
    end        
end
%��������ָ�꣬��ÿ������ڵĹ��򼯽�����������
Rule_sets_order1=cell(1,M); 
for s=1:M
    [Temp1,Order1_descend]=sortrows(Order1_index{1,s});
    Rule_sets_order1{1,s}=Rule_sets{1,s}(Order1_descend,:);
end

%����massֵ������ÿ�������������
Priori_probability=zeros(1,M); %����ÿ�����ǩ���������
for j=1:N1
    for s=1:M
        if isequal(Label_mass{j,1},Class_set{1,s})==1
            Priori_probability(1,s)=Priori_probability(1,s)+Label_mass{j,2};
            break
        end
    end
end
Priori_probability=Priori_probability/N1;
% %Priori_probability=Priori_probability/sum(Priori_probability); %������õ�������ʽ��й�һ��
%     
%��Rule_sets_Order1��˳���ó�ÿ������µĹ����������г�һ������󣬱�֤����ÿ��������ó��Ĺ���Ҳ��˳���ŷ�
Rule_sets_order=[];
upper_nn=max(nn);
Rule_subsets=cell(1,upper_nn); %ÿ����Ԫ�洢����ÿ��˳���飨�������е���𣩶�Ӧ�Ĺ��򼯺�
Num_subsets=zeros(1,upper_nn);   
for i=1:upper_nn
    Rule_subsets{1,i}=[]; %�洢Ϊ�������ʽ��ÿһ�б�ʾһ�ֹ���
    Order2_index=[]; %�洢Ϊ�������ʽ��ÿһ�д洢���˳��ָ�꣨��Ӧÿ������еĵ�i�����򼯺ϵ�����
    for s=1:M
        if size((Rule_sets_order1{1,s}),1)>=i  %Rule_sets_order1{1,s}
            Num_subsets(1,i)=Num_subsets(1,i)+1;
            Rule_subsets{1,i}(Num_subsets(1,i),:)=Rule_sets_order1{1,s}(i,:);
            Order2_index(Num_subsets(1,i),1)=-Rule_sets_order1{1,s}(i,P+3);
            Order2_index(Num_subsets(1,i),2)=-Rule_sets_order1{1,s}(i,P+2);
            Order2_index(Num_subsets(1,i),3)=-Priori_probability(1,Rule_sets_order1{1,s}(i,P+1));
        end
    end
    %�ϸ�forѭ���ͱ��������е�����ǩ�µĹ��򼯺�
    [Temp2,Order2_descend]=sortrows(Order2_index);
    %Order2_descend=flipud(Order2_ascend);
    if i==1
       Rule_sets_order(1:Num_subsets(1,1),:)=Rule_subsets{1,i}(Order2_descend,:);  
    else
       Rule_sets_order(sum(Num_subsets(1:i-1))+1:sum(Num_subsets(1:i)),:)=Rule_subsets{1,i}(Order2_descend,:);
    end
end
%time2=toc

%��3���������齨
%����Database coverage���������������Ĺ���˳���齨������
Classifier_rule_number=0; %�������й�����Ŀ
Classifier_rules=[]; %�洢Ϊ�������ʽ��������ʾ��Ӧ��һ������������P+3
%tic
for i=1:Num_after_deleting
    Antecedence=Rule_sets_order(i,1:P); %��ʾ��i�������ǰ��
    None_zero=find(Antecedence); %������,��¼����ķ�������ֵ��λ��
    T=[]; %�洢���ù���������ҷ�����ȷ�����������к�,������
    for j=1:N1
        %�ڱ�Antecedence������������У���û�б�������ȷ��
        flag3=1;
        for t=1:length(None_zero)
            if Mu{1,j}{None_zero(1,t),1}(1,Rule_sets_order(i,None_zero(1,t)))==0
                flag3=0;
                break
            end
        end
        if flag3==1 %����ܹ������j������
            if isequal(Label_mass{j,1},Class_set{1,Rule_sets_order(i,P+1)})==1 %�ҷ�����ȷ
                T=[T,j];
            end
        end
    end
    if size(T,2)>0
        Classifier_rule_number=Classifier_rule_number+1;
        Classifier_rules(Classifier_rule_number,:)=Rule_sets_order(i,:);
        %������ر�����ȥ����Щ��������ȷ��ѵ������
        TrainingData(T,:)=[];
        Label_mass(T,:)=[];
        Mu(:,T)=[];
    end
    N1=size(TrainingData,1);    %ȥ����������ȷ��ѵ��������õ���������Ŀ
    if N1==0   %����ڹ���û�����꣬����ѵ�������Ѿ�������ȷ�����ʱ�򣬾�ֹͣ�ж�
        disp('����ѵ�����ݶ�����ȷ����');
        break
    end
end

%��������Ĭ���౻����Ϊ�������������ʵ�����ǩ
[Value_default, Classifier_default]=max(Priori_probability);

Train_time=toc; %ѵ���������


%% ���Ĳ������ڷ������еĹ��򣬶Բ������ݽ��з��࣬���������ȷ��
tic
Classification_result=cell(N2,1);
True=zeros(N2,1);
TK=5; %TopK ���෽��
for i=1:N2
    [Test_Classification_result{i},Test_True(i,1)]=Classification(TestData(i,:),Classifier_rules,Classifier_default,Class_set,K,PointSets,TK,Num_class_original);
end
Test_True_rate=sum(Test_True)/N2; %��������в�����������ȷ������
Test_time=toc;     %��¼ѵ��ʱ��
Test_time=Test_time/N2;   
 
