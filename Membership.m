%2020.7.1
%子函数：根据所得到的离散点求隶属度函数
%分三种不同的情况：没有离散点，一个离散点，多于两个离散点
%结合了三角划分和梯形划分，模糊划分是基于0.5-cut的
%输入：x-数据中的某个属性值（数）；
%      Partition_points--不包括左右两端点的划分点数目
%      K--Partition_points集中所包括的点的数目
%输出：u-行向量，存储分配到每个区间下的隶属度值,所得到的隶属度区间没有考虑0.5cut
%2020.7.20--修改程序

function u=Membership(x,K,Partition_points)

n=K/2;  %离散点的数目
u=zeros(1,n+1); %对应的模糊区间数目比离散点的数目多1

%下面分三种情况对隶属度赋值
if x<=Partition_points(1)
    u(1)=1;
else if x>Partition_points(K)
        u(n+1)=1;
    else
        %说明x落在划分点中间
        if n==1  %只有一个离散点的情况，对应两个模糊划分
           u(1)=(Partition_points(2)-x)/(Partition_points(2)-Partition_points(1)); 
           u(2)=(x-Partition_points(1))/(Partition_points(2)-Partition_points(1));  
        else
            for j=2:n
                if x>Partition_points(2*j-3) & x<=Partition_points(2*j-2) %点落在左边的斜线
                    u(j-1)=(Partition_points(2*j-2)-x)/(Partition_points(2*j-2)-Partition_points(2*j-3));
                    u(j)=(x-Partition_points(2*j-3))/(Partition_points(2*j-2)-Partition_points(2*j-3));
                else if x>Partition_points(2*j-1) & x<=Partition_points(2*j)  %点落在右边的斜线
                        u(j)=(Partition_points(2*j)-x)/(Partition_points(2*j)-Partition_points(2*j-1));
                        u(j+1)=(x-Partition_points(2*j-1))/(Partition_points(2*j)-Partition_points(2*j-1));
                    else if x>Partition_points(2*j-2) & x<=Partition_points(2*j-1)  %中间的两个点不重合
                            u(j)=1;
                        end
                    end
                end
            end
        end
    end
end

















