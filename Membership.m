%2020.7.1
%�Ӻ������������õ�����ɢ���������Ⱥ���
%�����ֲ�ͬ�������û����ɢ�㣬һ����ɢ�㣬����������ɢ��
%��������ǻ��ֺ����λ��֣�ģ�������ǻ���0.5-cut��
%���룺x-�����е�ĳ������ֵ��������
%      Partition_points--�������������˵�Ļ��ֵ���Ŀ
%      K--Partition_points�����������ĵ����Ŀ
%�����u-���������洢���䵽ÿ�������µ�������ֵ,���õ�������������û�п���0.5cut
%2020.7.20--�޸ĳ���

function u=Membership(x,K,Partition_points)

n=K/2;  %��ɢ�����Ŀ
u=zeros(1,n+1); %��Ӧ��ģ��������Ŀ����ɢ�����Ŀ��1

%�������������������ȸ�ֵ
if x<=Partition_points(1)
    u(1)=1;
else if x>Partition_points(K)
        u(n+1)=1;
    else
        %˵��x���ڻ��ֵ��м�
        if n==1  %ֻ��һ����ɢ����������Ӧ����ģ������
           u(1)=(Partition_points(2)-x)/(Partition_points(2)-Partition_points(1)); 
           u(2)=(x-Partition_points(1))/(Partition_points(2)-Partition_points(1));  
        else
            for j=2:n
                if x>Partition_points(2*j-3) & x<=Partition_points(2*j-2) %��������ߵ�б��
                    u(j-1)=(Partition_points(2*j-2)-x)/(Partition_points(2*j-2)-Partition_points(2*j-3));
                    u(j)=(x-Partition_points(2*j-3))/(Partition_points(2*j-2)-Partition_points(2*j-3));
                else if x>Partition_points(2*j-1) & x<=Partition_points(2*j)  %�������ұߵ�б��
                        u(j)=(Partition_points(2*j)-x)/(Partition_points(2*j)-Partition_points(2*j-1));
                        u(j+1)=(x-Partition_points(2*j-1))/(Partition_points(2*j)-Partition_points(2*j-1));
                    else if x>Partition_points(2*j-2) & x<=Partition_points(2*j-1)  %�м�������㲻�غ�
                            u(j)=1;
                        end
                    end
                end
            end
        end
    end
end

















