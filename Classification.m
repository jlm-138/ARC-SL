%子函数：对测试数据分类,测试数据是硬标签
%输入：TestData-某一个测试数据，1*(P+1)行向量，P-属性数目
%      Classifier_rules--分类器中的规则，行数是规则数目，列数是P+3
%      Classifier_default--默认类（数），表示类别集中的哪一个类
%      Class_set--1*M胞元，每个胞元存储的一个可能的类
%      K--1*P行向量,每个属性下的模糊划分点的数目，不包括两侧的边界点；
%      PointSets--cell(1,P)，每个胞元是一个行向量，存储在每个属性下的划分点，维数与K(i)大小相同
%      Num_class-原始数据中单类别的数目
%      Decision_criterion:表示判断是软决策还是硬决策； 1--硬决策， 0--软决策
%      TK--分类所需要所融合的规则数目
%输出：Result--该测试数据的类别，单个数值；True--分类正确时为1，否则为0；

% 2020.7.25--利用证据框架下的D-S组合推理分类，TopK方法融合被激活的规则
%8.3--程序存在bug:对于类标签不连续的情况（所采集的数据集中没有某种类别），会出现错误---对数据集作预处理


function [Result,True]=Classification(TestData,Classifier_rules,Classifier_default,Class_set,K,PointSets,TK,Num_class)

%先判断是不是学到了规则
n=size(Classifier_rules,1);
if n>0
    P=length(TestData)-1; %样本的属性数目
    %对测试数据的属性值作模糊划分
    A=cell(P,1);  %计算TestData每个属性值在相应模糊区间下的的隶属度值
    for i=1:P
        %A{i,1}=zeros(1,K(i));
        for j=1:K(i)
            A{i,1}=Membership(TestData(1,i+1),K(i),PointSets{i}); %这个地方是没有基于0.5cut的
            A{i,1}(find(A{i,1}<0.5))=0;
            %A{i,1}(find(A{i,1}>=0.5))=1;
        end
    end
    
    %计算输入样本对每一个分类规则的激活度大小
    if n<TK %如果分类器中的规则数目小于TK
        TK=n;
    end
    
    d=zeros(1,n);  %存储每个规则对应的激活度
    for i=1:n
        Location_attr=find(Classifier_rules(i,1:P)); %哪些位置的属性值不为0
        Num_attr=length(Location_attr);
        Activated_degree_vector=zeros(1,Num_attr);  %存储被测试样本所激活的规则在每个前提属性下的激活度的值
        for j=1:Num_attr
            Activated_degree_vector(1,j)=A{Location_attr(j),1}(1,Classifier_rules(i,Location_attr(j)));
            if Activated_degree_vector(1,j)==0
                break
            end
        end
        d(1,i)=(prod(Activated_degree_vector))^(1/Num_attr);
    end
    
    if d==0 %表示输入样本没有激活任何规则，按照默认类设置
        Result=str2double(Class_set{1,Classifier_default}); %结果是某个类，比如结果1就表示类别是w1；也可能是向量的形式（如果无法判断是哪一个类的时候）
    else
        %提取TOP K规则集--Fused_rules(有可能前TK个规则没有被全部激活)
        [dd,Order]=sort(d,'descend');
        if min(dd(1,1:TK))>0  %判断下是否能够激活前TK个激活度值对应的规则
            Fused_rules=Classifier_rules(Order(1:TK),:);
        else
            Num_activated=length(find(dd));
            Fused_rules=Classifier_rules(Order(1:Num_activated),:);
        end
        
        %存储Fused_rules中相对应每个规则的折扣因子factor（激活度*规则置信度）
        Num_fused=size(Fused_rules,1);
        alpha=zeros(1,Num_fused);
        for i=1:Num_fused
            alpha(i)=Fused_rules(i,P+3)*dd(i);
        end
        
        %存储每个互异的焦元素对应不同规则集的因子（相应的mass值）--Category_rule_factors
        Index_class=unique(Fused_rules(:,P+1)); %需要融合的规则集中的互异类别
        f=length(Index_class);
        Category_rule_factors=cell(1,f); %存储每种焦元素下对应规则集的折扣因子大小
        ff=zeros(1,f); %记录在Index_class种每个焦元素下的规则数目
        for i=1:f
            for j=1:Num_fused
                if Fused_rules(j,P+1)==Index_class(i,1)
                    ff(1,i)=ff(1,i)+1;
                    Category_rule_factors{1,i}(ff(1,i),1)=alpha(j);
                end
            end
        end
        
        %组合Fused_rules中所有规则对应的mass函数，求每个互异焦元素（类别）的Mass值（最后归一化）
        Mass_unormalized=zeros(1,f+1); %前f个位置分别存储Index_class中前f个焦元素的mass值
        Mass_unormalized(1,f+1)=prod(1-alpha);%分配给未知的置信
        for s=1:f
            %第一种焦元的组合形式：ff(s)个mass函数取焦元素f_s，另外的mass函数取整个辨识框架(S1)
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
            %第二种焦元素组合形式：焦元素是s的mass函数中有一个取该焦元素，其它所有mass函数都取整个辨识框架
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
        Mass=Mass_unormalized/sum(Mass_unormalized);  %存储归一化后的mass分布
        
        %if Decsion_criterion==1
        %调用子函数：将Mass函数转化为单个类别下的pignistic概率，赋给概率值最大的类别
        Focal_elements=cell(1,f);
        for i=1:f
            Focal_elements{1,i}=Class_set{1,Index_class(i)};
        end
        Pignistic_values=Pignistic(Focal_elements,Mass(1:f),Mass(f+1),Num_class);
        Result=[];
        %提取最大pignistic值对应的所有索引
        for i=1:Num_class
            if Pignistic_values(1,i)==max(Pignistic_values)
                Result=[Result,i];
            end
        end
    end
else
    %如果分类器中没有规则，就直接分配给默认类
    Result=str2double(Class_set{1,Classifier_default});
end
    
    %判断是否分类正确？--如果结果中有多个类别，只要与其中一个类别一致，就认为分类正确
    if ismember(TestData(1,1),Result)==1
        True=1;
    else
        True=0;
    end
    
end






