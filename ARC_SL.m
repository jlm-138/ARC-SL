% ARC_SL: Association rule-based classification with soft labels
% Copyright (C) 2021-2022, by Lianmeng Jiao (jiaolianmeng@nwpu.edu.cn)

function [Test_Classification_result,Test_True_rate,Classifier_rules,Class_set,Classifier_rule_number,Total_rule_number,Train_time,Test_time]=ARC_SL(TrainingData,TestData,Label_mass,N1,N2,Num_class_original)

tic
P=size(TrainingData,2)-1; %属性个数

%几个可调节的参数
minsup=0.01; 
minconf=0.5; 
Max_fre_ruleitem=20000; %给频繁规则项设置一个最大上限值

%% 第一步：基于Fayyad离散化方法对连续属性进行模糊划分

%先将每个训练样本分配给‘软’类标签，即为除了整个辨识框架之外的其他焦元素对应的最大mass（对于简单Mass,即为主焦元）
Ambiguous_label=cell(N1,1);
for j=1:N1
    Ambiguous_label{j}=Label_mass{j,1}; 
end

%基于所分配的软标签以及属性值，利用Fayyad离散化思想得到分割点集
K=zeros(1,P); % 每个属性下的模糊划分数
PointSets=cell(1,P); %每个属性下的切割点集（连同最小以及最大值）
%Attributes_judge=ones(1,P); %判断属性是不是被保留（考虑），根据离散化能不能得到离散点
Num_disc=zeros(1,P); %存储每个维度下的离散点数目
Disc=cell(1,P); %存储每个维度下计算出来的离散点集合
%tic
for i=1:P
    X=TrainingData(:,i+1); %表示第i个属性的所有属性值集合
    a=min(X); %左端点
    b=max(X); %右端点
    Disc{i}=Fayyad_test(X,Ambiguous_label,Label_mass);  %调用子函数，得到分割点的集合,行向量
   %Disc=Fayyad(X,Ambiguous_label,Label_mass); 
%     Disc=FuzzyGrid(X,3);  %调用子函数，得到分割点的集合,行向量(fuzzy grid)
   %找出对应该属性的模糊划分点---PointSets{i}
    Num_disc(i)=length(Disc{i});  %所学到的离散点的数目
    if Num_disc(i)==0
        %Attributes_judge(1,i)=0; 
        K(i)=0;
    else
        d=zeros(1,Num_disc(i)+1);  %存储由左右端点以及离散点所分割出来的Num_disc(i)+1个区间长度
        d(1)=Disc{i}(1)-a;
        d(Num_disc(i)+1)=b-Disc{i}(Num_disc(i));
        for j=2:Num_disc(i)
            d(j)=Disc{i}(j)-Disc{i}(j-1);
        end
        [dd,Index_min]=min(d);
        %在每个离散点的两侧作长度为dd/2的点，每个离散点的两侧都能得到划分点
        PointSets{i}=zeros(1,2*Num_disc(i));
        for j=1:Num_disc(i)
            PointSets{i}(1,2*j-1)=Disc{i}(j)-dd/2;
            PointSets{i}(1,2*j)=Disc{i}(j)+dd/2;
        end
        %得到的划分点中可能会存在某两个点相等的情况（点重合），说明对应的区间长度正好是最小的
    end
    K(i)=length(PointSets{i}); %该属性下的模糊划分点数，是离散点数目的二倍
end
%time_discret=toc; %记录下离散化的时间

%基于上面所得到的模糊划分点集，作梯形模糊划分，对每个训练样本分配模糊隶属度值
Mu=cell(1,N1);
for j=1:N1
    Mu{1,j}=cell(P,1);
    for i=1:P
        if Num_disc(i)>0  %考虑有离散点的属性对应的模糊划分
           Mu{1,j}{i,1}=Membership(TrainingData(j,i+1),K(i),PointSets{i}); 
           Mu{1,j}{i,1}(find(Mu{1,j}{i,1}<0.5))=0; %将小于0.5的隶属度截掉
           %Mu{1,j}{i,1}(find(Mu{1,j}{i,1}>=0.5))=1; %对应的是硬化分，为了检验程序
        end
    end
end
   
%% 第二步：基于上面对样本的模糊划分，利用Apriori算法从软标签的样本数据中挖掘规则
%tic
%将训练样本的软标签中除了整个辨识框架之外的其他焦元素作为可能类别集合,存储为行胞元
M=1; %训练数据中‘软’类别数目
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

Freq_ruleitems=cell(1,P);  %得到不同属性数目下的频繁规则项
Num_ruleitems=zeros(1,P); %表示不同属性数目下频繁规则项的数目
Sup_fre_ruleitems=cell(1,P); %存储上面每个频繁规则项对应的支持度
Conf_rules=cell(1,P); %存储上面每个频繁规则项对应的置信度

Num_rules=zeros(1,P);  %表示不同属性数目下规则的数目
Mined_rules=cell(1,P); 

%求出训练集中每个类别出现的次数
Num_class=zeros(1,M);
for s=1:M
    for i=1:N1
        %方案一：直接利用最大Mass所对应的类别作为样本的类别标签
%          if isequal(Label_mass{i,1},Class_set{1,s})==1  
%              Num_class(1,s)=Num_class(1,s)+1;
%          end
       %方案二：利用所考虑的类别在每个样本中的mass值
       if isequal(Label_mass{i,1},Class_set{1,s})==1
          Num_class(1,s)=Num_class(1,s)+Label_mass{i,2};
       end
    end
end

%列出所有的频繁1-ruleitems，对应求出只有一个模糊区间的规则
Num_ruleitems(1,1)=0; 
Num_rules(1,1)=0; 
Freq_ruleitems{1,1}=[]; %存储为矩阵：行数是Num_ruleitems(1,1)，列数是P+1，前P列是项，第P+1列是对应Class_set中的位置索引
Sup_fre_ruleitems{1,1}=[]; %列向量,行数是 Num_ruleitems(1,1)
Conf_rules{1,1}=[]; %列向量,行数是 Num_rules(1,1)
Mined_rules{1,1}=[]; %矩阵：行数是规则数目，列数是P+3,后三列分别为类别索引值，支持度和置信度（每一行代表一个规则）
for i=1:P
    if Num_disc(i)>0
    Item=zeros(1,P);
    for t=1:(Num_disc(i)+1)
        Item(1,i)=t;
        Sup_ruleitem=zeros(1,M); %存储Item对应结论Class_set{1,S}的支持度
        Conf_temple=zeros(1,M);
        for s=1:M
           %调用子函数Support_ruleitem:同时输出前提项和规则项的支持度
           [Sup_item,Sup_ruleitem(1,s)]=Support_Ruleitem(Item,Mu,Class_set,s,Label_mass); 
            c=Num_class(1,s)/max(Num_class);  %该系数是用来设置自适应阈值
            if Sup_ruleitem(1,s)>=minsup*c
            %if Sup_temple(1,s)>=minsup
                Num_ruleitems(1,1)=Num_ruleitems(1,1)+1;
                Freq_ruleitems{1,1}(Num_ruleitems(1,1),1:P)=Item;
                Freq_ruleitems{1,1}(Num_ruleitems(1,1),P+1)=s;
                Sup_fre_ruleitems{1,1}(Num_ruleitems(1,1),1)=Sup_ruleitem(1,s);
                
                %利用置信度的值，给出相应规则
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

%调用子函数，按照Apriori算法的思想组合得出频繁k-ruleitems
if Num_ruleitems(1,1)< Max_fre_ruleitem
    for k=1:P-1
        %tic
        [Freq_ruleitems{1,k+1},Sup_fre_ruleitems{1,k+1},Confidence,Num_ruleitems(1,k+1)]=CandidateGen(k,Freq_ruleitems{1,k},P,Mu,Class_set,Label_mass,minsup,Num_class);
        %time_frequent_mining=toc
        %根据频繁项生成规则
        Num_rules(1,k+1)=0;
        Mined_rules{1,k+1}=[];
        for j=1:Num_ruleitems(1,k+1) %第j个频繁(k+1）-项集
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
     
        %判断项数有没有超出上限，要不要继续挖掘频繁项
        if sum(Num_ruleitems(1,1:k+1))>= Max_fre_ruleitem
            disp('Up to the Fre_limits');
            break
        end %若学到的频繁项集总数超过一定的上限值，就不再挖掘频繁项
    end
end
Total_rule_number=sum(Num_rules); %表示挖掘的总的规则数目
%time_mining=toc; 

%% 第三步：Pruning from the mined rules for building the classifier

%tic  %规则削减中的第一部分是最费时间的，因为挖掘到的规则数目较多
%（1）从Mined_rules中去除冗余规则
% Using general and high confidence for deleting specific and low confidence rules
Delete_rules=Mined_rules;  %存储第一步削减后的规则集，存储形式与挖掘到的规则存储形式相同
Num_delete_rules=zeros(1,P); %Delete_Rules中，不同属性数目对应的规则数目
%tic
for k=P:-1:2
    Delete_rows=[];   %删除Mined_rules{1,k}中哪些行数的规则？
    Num_Delete_rows=0; 
    if Num_rules(1,k)~=0 & Num_rules(1,k-1)~=0 
        for i=1:Num_rules(1,k)  
            Ant_item=Mined_rules{1,k}(i,1:P); %含有k个前提属性模糊集中的第i个规则对应的前提项
            for j=1:k   %有k种子集的情况
                Subset_Ant_item=Ant_item;  %行向量
                Replace_location=find(Ant_item);  
                Subset_Ant_item(1,Replace_location(1,j))=0; %得到原规则前提项的一个子集
                
                %看看上面得到的规则子集是不是在含有k-1个前提属性的规则集中
                [Value,Index_row]=ismember(Subset_Ant_item,Mined_rules{1,k-1}(:,1:P),'rows');
                %Value是逻辑值，若存在相同的，就返回1；否则为0；Index_row为矩阵中与前面向量相同的行（最后一次出现相同的那一行）
                if Value==1
                    if Mined_rules{1,k}(i,P+3)<= Mined_rules{1,k-1}(Index_row,P+3) && Mined_rules{1,k}(i,P+1)== Mined_rules{1,k-1}(Index_row,P+1) %规则类别不同
                     %if Mined_rules{1,k}(i,P+3)<= Mined_rules{1,k-1}(Index_row,P+3) %不考虑规则类别
                        Num_Delete_rows=Num_Delete_rows+1;
                        Delete_rows(1,Num_Delete_rows)=i;
                        break
                        %只要规则中存在一个这样的子集，就不再遍历其他的规则子集情况，跳出循环；
                    end
                end
            end
        end
    end
    Delete_rules{1,k}(Delete_rows,:)=[]; %在前提属性数目是k的规则集中去掉相应行数的规则
    Num_delete_rules(1,k)=size(Delete_rules{1,k},1);
end
Num_delete_rules(1,1)=size(Delete_rules{1,1},1);
Num_after_deleting=sum(Num_delete_rules); %表示削减后的规则数目
%time1=toc

%（2）对规则进行排序
%将上一步得到的规则集Delete_rules按照类别不同存储在胞元数组Rule_sets中，并存储排序指标
Rule_sets=cell(1,M); %每个胞元存储的是具有不同类别的rules
Order1_index=cell(1,M); %组内排序的指标，分别为置信度，支持度和规则生成的顺序
nn=zeros(1,M);  %存储每个类别胞元下对应的规则数
%tic
for k=1:P
    for i=1:size(Delete_rules{1,k},1)
        for s=1:M
            if Delete_rules{1,k}(i,P+1)==s
                nn(s)=nn(s)+1;
                Rule_sets{1,s}(nn(s),:)=Delete_rules{1,k}(i,:);
                %考虑到排序命令sortrows只支持升序排列，所以置信度和支持度比较的时候取负
                Order1_index{1,s}(nn(s),1)=-Delete_rules{1,k}(i,P+3); %置信度
                Order1_index{1,s}(nn(s),2)=-Delete_rules{1,k}(i,P+2); %支持度
            end
        end
    end        
end
%按照排序指标，对每个类别内的规则集进行组内排序
Rule_sets_order1=cell(1,M); 
for s=1:M
    [Temp1,Order1_descend]=sortrows(Order1_index{1,s});
    Rule_sets_order1{1,s}=Rule_sets{1,s}(Order1_descend,:);
end

%利用mass值，计算每个类别的先验概率
Priori_probability=zeros(1,M); %计算每个类标签的先验概率
for j=1:N1
    for s=1:M
        if isequal(Label_mass{j,1},Class_set{1,s})==1
            Priori_probability(1,s)=Priori_probability(1,s)+Label_mass{j,2};
            break
        end
    end
end
Priori_probability=Priori_probability/N1;
% %Priori_probability=Priori_probability/sum(Priori_probability); %对所求得的先验概率进行归一化
%     
%从Rule_sets_Order1中顺序拿出每个类别下的规则，纵向排列成一个大矩阵，保证按照每个类别下拿出的规则也是顺序排放
Rule_sets_order=[];
upper_nn=max(nn);
Rule_subsets=cell(1,upper_nn); %每个胞元存储的是每个顺序组（遍历所有的类别）对应的规则集合
Num_subsets=zeros(1,upper_nn);   
for i=1:upper_nn
    Rule_subsets{1,i}=[]; %存储为矩阵的形式，每一行表示一种规则
    Order2_index=[]; %存储为矩阵的形式，每一行存储相关顺序指标（对应每个类别中的第i个规则集合的排序）
    for s=1:M
        if size((Rule_sets_order1{1,s}),1)>=i  %Rule_sets_order1{1,s}
            Num_subsets(1,i)=Num_subsets(1,i)+1;
            Rule_subsets{1,i}(Num_subsets(1,i),:)=Rule_sets_order1{1,s}(i,:);
            Order2_index(Num_subsets(1,i),1)=-Rule_sets_order1{1,s}(i,P+3);
            Order2_index(Num_subsets(1,i),2)=-Rule_sets_order1{1,s}(i,P+2);
            Order2_index(Num_subsets(1,i),3)=-Priori_probability(1,Rule_sets_order1{1,s}(i,P+1));
        end
    end
    %上个for循环就遍历完所有的类别标签下的规则集合
    [Temp2,Order2_descend]=sortrows(Order2_index);
    %Order2_descend=flipud(Order2_ascend);
    if i==1
       Rule_sets_order(1:Num_subsets(1,1),:)=Rule_subsets{1,i}(Order2_descend,:);  
    else
       Rule_sets_order(sum(Num_subsets(1:i-1))+1:sum(Num_subsets(1:i)),:)=Rule_subsets{1,i}(Order2_descend,:);
    end
end
%time2=toc

%（3）分类器组建
%根据Database coverage方法，按照排序后的规则顺序组建分类器
Classifier_rule_number=0; %分类器中规则数目
Classifier_rules=[]; %存储为矩阵的形式，行数表示对应哪一个规则，列数是P+3
%tic
for i=1:Num_after_deleting
    Antecedence=Rule_sets_order(i,1:P); %表示第i个规则的前提
    None_zero=find(Antecedence); %行向量,记录规则的非零属性值的位置
    T=[]; %存储被该规则所激活，且分类正确的样本的序列号,行向量
    for j=1:N1
        %在被Antecedence所激活的样本中，有没有被分类正确？
        flag3=1;
        for t=1:length(None_zero)
            if Mu{1,j}{None_zero(1,t),1}(1,Rule_sets_order(i,None_zero(1,t)))==0
                flag3=0;
                break
            end
        end
        if flag3==1 %如果能够激活第j个样本
            if isequal(Label_mass{j,1},Class_set{1,Rule_sets_order(i,P+1)})==1 %且分类正确
                T=[T,j];
            end
        end
    end
    if size(T,2)>0
        Classifier_rule_number=Classifier_rule_number+1;
        Classifier_rules(Classifier_rule_number,:)=Rule_sets_order(i,:);
        %更新相关变量，去除那些被分类正确的训练样本
        TrainingData(T,:)=[];
        Label_mass(T,:)=[];
        Mu(:,T)=[];
    end
    N1=size(TrainingData,1);    %去除被分类正确的训练样本后得到的样本数目
    if N1==0   %如果在规则还没有用完，但是训练样本已经都被正确分类的时候，就停止判断
        disp('所有训练数据都被正确分类');
        break
    end
end

%分类器的默认类被设置为具有最高先验概率的类别标签
[Value_default, Classifier_default]=max(Priori_probability);

Train_time=toc; %训练过程完成


%% 第四步：基于分类器中的规则，对测试数据进行分类，计算分类正确率
tic
Classification_result=cell(N2,1);
True=zeros(N2,1);
TK=5; %TopK 分类方法
for i=1:N2
    [Test_Classification_result{i},Test_True(i,1)]=Classification(TestData(i,:),Classifier_rules,Classifier_default,Class_set,K,PointSets,TK,Num_class_original);
end
Test_True_rate=sum(Test_True)/N2; %计算对所有测试样本的正确分类率
Test_time=toc;     %记录训练时间
Test_time=Test_time/N2;   
 
