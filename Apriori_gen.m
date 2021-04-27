%input:F(k)
%outpt:F(k+1); F(k+1)中每个项对应的支持度； L: F(k+1)中含有的频繁项的个数

function [EF2,sup,L]=Apriori_gen(EF1,k,P,AT,min_sup)

EF2=[];
sup=[];
L=0; % EF2中频繁项的个数

%N=size(TrainingData,1);
m=size(EF1,1);
if m>1
    if k==1   %由1到2组合
        for i1=1:m-1
            for i2=(i1+1):m
                location_1=find(EF1(i1,1:P)); %寻找EF1中第i1项对应哪一个模糊区间
                location_2=find(EF1(i2,1:P));
                if location_1<location_2  %当模糊区间是不同属性下的
                    C=zeros(1,P); %存储每一种可能的组合后的前提项
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
        for j1=1:m-1   %EF中的第j1项
            for j2=(j1+1):m  %EF中的第j2项
                %combination 
                vector_location_1=find(EF1(j1,1:P)); %寻找EF_k中第j1项对应哪几个模糊区间的乘积
                vector_location_2=find(EF1(j2,1:P));
                if vector_location_1(1,1:k-1)==vector_location_2(1,1:k-1) & vector_location_1(1,k)<vector_location_2(1,k)
                    if EF1(j1,vector_location_1(1,1:k-1))==EF1(j2,vector_location_2(1,1:k-1))
                        C=zeros(1,P);
                        C(1,vector_location_1(1,1:k-1))=EF1(j1,vector_location_1(1,1:k-1));
                        C(1,vector_location_1(1,k))=EF1(j1,vector_location_1(1,k));
                        C(1,vector_location_2(1,k))=EF1(j2,vector_location_2(1,k));
                        
                        %方案一：去掉pruning部分
                        sup2_item=sup_item(C,AT);
                        if sup2_item>=min_sup
                            L=L+1;
                            EF2(L,:)=C;
                            sup(L,1)=sup2_item;
                        end
                        
                        %方案二：pruning+support computing 
%                         location=[vector_location_1(1,1:k) vector_location_2(1,k)]; %表示新组合后的模糊区域的非零元素位置
%                         subset=zeros(k+1,P);  %将所有的子集情况存储为矩阵的形式，行数表示的k+1中子集种类的数目
%                         for s=1:k+1
%                             subset(s,1:P)=C;
%                             subset(s,location(1,s))=0;  %将C中的第s个元素替换0，其他相同
%                         end
%                         logical_value=ismember(subset,EF1,'rows'); %得到一个逻辑值列向量，判断其子集是不是频繁k-ruleitems的前提中
%                         if logical_value==ones(k+1,1)  %如果C的任意子集都是频繁的
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
%组合结束
end 
                            

        
        
        
        
   
    








