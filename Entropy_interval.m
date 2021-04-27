%子函数：基于属性值序列（列向量）以及对应每个属性值下样本的软标签（列胞元），对特定位置的样本数据求熵值
%输入：X--属性值，列向量；Label_Mass-对应该属性值下样本的类别mass函数，N*2的胞元，分别存储焦元素以及相应mass值
%     Index--列向量，表示所求的是对应哪些位置的数据集？

function EntS=Entropy_interval(Index,Label_Mass)

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

%方案1：将整个辨识框架也作为其中的一个焦元素
% Mass_remaining=1-sum(Mass); %表示分配给整个辨识框架下的mass
% %求该区间内的熵值
% EntS=0;
% for i=1:m
%     EntS=EntS-Mass(1,i)*log2(Mass(1,i));
% end
% if Mass_remaining>0 %如果分配给整个辨识框架的mass大于0，将这部分也包括进去
%     EntS=EntS-Mass_remaining*log2(Mass_remaining);
% end

%方案2：整个辨识框架不作为焦元素，其他的mass进行归一化（与后面判定的时候统计类标签的数目一致，不包括整个辨识框架）
 Mass=Mass/sum(Mass);
 EntS=0;
 for i=1:m
     EntS=EntS-Mass(1,i)*log2(Mass(1,i));
 end

end

 



    
    















