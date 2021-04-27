%子函数：将mass函数转化为pignistic概率值
%输入： Focal--1*m cell,每个cell内部也存储为cell(表示这个焦元素有多少个类)，存储除整个辨识框架之外的其他焦元素
      % Mass-- 1*m vecctor,存储Focal中对应焦元素的mass值
      % Mass_remaining--数，存储整个辨识框架下的mass值
      % N--数，表示整个辨识框架中元素数目
%输出：Probability_Value--Num_class*1

function Probability_Value=Pignistic(Focal,Mass,Mass_remaining,N)

Probability_Value=zeros(1,N);
M=length(Mass);      %统计焦元素个数
for i=1:N
    for j=1:M
         n=length(Focal{1,j});
         if n==1    %若只含有单个焦元素
            Temple=Focal{1,j}{1,1}; 
         else
             Temple=cell(1,n);
             for t=1:n
                 Temple{1,t}=Focal{1,j}{1,t};
             end
         end
         intersection=intersect(Temple,num2str(i));  
        if isempty(intersection)==0
            %统计与所求元素有交集的焦元素中所含元素个数
            n=length(Temple); 
            Probability_Value(1,i)= Probability_Value(1,i)+Mass(1,j)/n ;
        end
    end
end

%将整个辨识框架内的mass值平均分配给每一个单焦元素
if Mass_remaining>0
    Probability_Value=Probability_Value+Mass_remaining/N;
end

end
