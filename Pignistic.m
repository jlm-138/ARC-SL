%�Ӻ�������mass����ת��Ϊpignistic����ֵ
%���룺 Focal--1*m cell,ÿ��cell�ڲ�Ҳ�洢Ϊcell(��ʾ�����Ԫ���ж��ٸ���)���洢��������ʶ���֮���������Ԫ��
      % Mass-- 1*m vecctor,�洢Focal�ж�Ӧ��Ԫ�ص�massֵ
      % Mass_remaining--�����洢������ʶ����µ�massֵ
      % N--������ʾ������ʶ�����Ԫ����Ŀ
%�����Probability_Value--Num_class*1

function Probability_Value=Pignistic(Focal,Mass,Mass_remaining,N)

Probability_Value=zeros(1,N);
M=length(Mass);      %ͳ�ƽ�Ԫ�ظ���
for i=1:N
    for j=1:M
         n=length(Focal{1,j});
         if n==1    %��ֻ���е�����Ԫ��
            Temple=Focal{1,j}{1,1}; 
         else
             Temple=cell(1,n);
             for t=1:n
                 Temple{1,t}=Focal{1,j}{1,t};
             end
         end
         intersection=intersect(Temple,num2str(i));  
        if isempty(intersection)==0
            %ͳ��������Ԫ���н����Ľ�Ԫ��������Ԫ�ظ���
            n=length(Temple); 
            Probability_Value(1,i)= Probability_Value(1,i)+Mass(1,j)/n ;
        end
    end
end

%��������ʶ����ڵ�massֵƽ�������ÿһ������Ԫ��
if Mass_remaining>0
    Probability_Value=Probability_Value+Mass_remaining/N;
end

end
