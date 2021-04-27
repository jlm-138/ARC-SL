%2020.5.25
%子函数：求某个集合内的熵值--计算熵值的时候利用pignistic，不是用mass

function EntS=Entropy_interval_pignistic(Index,Label_Mass)

global Num_class
Number = Num_class;
I=length(Index);

%所考虑的样本集的焦元素集合（不包括焦元素是整个辨识框架）
Focal={};
Focal{1,1}=Label_Mass{Index(1),1}; %初始化
m=1; % 用来记录焦元素的数目
for i=2:I
    Temp=Label_Mass{Index(i),1};
    %比较下焦元Temp与前i-1个焦元素中是不是有重复的？
    flag=1;
    for j=1:i-1
        if isequal(Temp,Label_Mass{Index(j),1})==1 %如果有相同的
            flag=0;
            break
        end
    end
    if flag==1
        m=m+1;
        Focal{1,m}=Temp; %赋予新的焦元
    end
end

%对上面求得的每个焦元素分配mass值
Mass=zeros(1,m); %每个焦元素下的mass值
for i=1:I
    for j=1:m
        if isequal(Label_Mass{Index(i),1},Focal{1,j})==1
            Mass(1,j)=Mass(1,j)+Label_Mass{Index(i),2};
            break
        end
    end
end
Mass=Mass/I;
Mass_remaining=1-sum(Mass); %表示分配给整个辨识框架下的mass

%调用子函数,求mass函数对应的每个单个焦元素的pignistic值
Probability_vector=Pignistic(Focal,Mass,Mass_remaining,Number); 

%求该区间内的熵值
EntS=0;
for i=1:Number
    if Probability_vector>0
       EntS=EntS-Probability_vector(1,i)*log2(Probability_vector(1,i));
    end
end

end

    
    





