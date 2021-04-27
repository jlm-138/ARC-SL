%子函数：判断在某些索引位置下的样本的软标签类别数目
%输入：Index-列向量，表示位置索引； Ambiguous_label--软标签，对应每个训练样本的软标签，列胞元 

function k=Num_class(Index,Ambiguous_label,Label_Mass)

L=length(Index); 
k=1; 
for i=2:L
    flag=1;
    for j=1:i-1
        if isequal(Ambiguous_label{Index(i),1},Ambiguous_label{Index(j),1})==1
            flag=0;
            break
        end
    end
    if flag==1
        k=k+1;
    end
end

% 考虑辨识框架(对应于方案1：将整个辨识框架也作为其中的一个焦元素)
IsOmega = 0;
for i=1:L
    if Label_Mass{Index(i),2} ~= 1
        IsOmega = 1;
        break
    end
end
if IsOmega == 1
    k = k + 1;
end

