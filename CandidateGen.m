%子函数：基于Apriori的思想，从含有k个模糊区间的频繁规则项组合得到含有k+1个模糊区间的频繁规则项的过程
%输入：k-现有频繁规则项中模糊前提的数目；
%      F1-现有的频繁规则项,存储为行数是频繁项的数目，列数是P+1的矩阵；
%      P-样本中属性的数目； Mu-训练样本属性值在每个模糊划分下的隶属度值，cell(1,N)
%      Label_mass-指的是训练样本对应的软标签，分别存储对应的焦元素以及mass值，cell(N,2)
%输出: F2-频繁规则项,存储形式与FreqRuleitems_initial类似；
%      Sup_ruleitems-频繁规则项的支持度，列向量，行数与FreqRuleitems一致
%      Conf_ruleitems--对应规则的置信度，列向量
%7.29- 46行与90行计算支持度，没有按照修改过来的公式计算-对精确情况下没有影响

function [F2,Sup_ruleitems,Conf_ruleitems,Num2]=CandidateGen(k,F1,P,Mu,Class_set,Label_mass,minsup,Num_class)

N=length(Mu);    %表示训练样本的数目
Num1=size(F1,1); %表示F1中频繁项的数目
Num2=0; %记录F2中频繁项的个数
F2=[];
Sup_ruleitems=[];
Conf_ruleitems=[];

if Num1>1
    Class_index=unique(F1(:,P+1));
    m=length(Class_index);  %F1中的频繁规则项对应规则的结论类别有多少种？

    if k==1 %从1-ruleitem到2-ruleitem,将类别相同的进行组合
        %先将类别归类
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
                       
                       %计算ruleitem C1的支持度
                        [Sup_A,Sup]=Support_Ruleitem(C1(1,1:P),Mu,Class_set,s,Label_mass);
                       
                       c1=Num_class(1,s)/max(Num_class);  %给出自适应阈值系数
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
        %下面考虑初始的规则项数目大于等于2时，按照Apriori原则组合的情况
        for s=1:m
            ff1=F1(find(F1(:,P+1)==s),:); %对应类别是s的频繁规则项
            nn=size(ff1,1);
            for i=1:nn-1   %EF中的第j1项
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
                            
                            %计算规则项C2的支持度
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
        
            
                           
                           
                          
                           
                           
                       
                       
                    
            
        
        
        
        
        
        
        
        

