%2020.5.25
%�Ӻ�������ĳ�������ڵ���ֵ--������ֵ��ʱ������pignistic��������mass

function EntS=Entropy_interval_pignistic(Index,Label_Mass)

global Num_class
Number = Num_class;
I=length(Index);

%�����ǵ��������Ľ�Ԫ�ؼ��ϣ���������Ԫ����������ʶ��ܣ�
Focal={};
Focal{1,1}=Label_Mass{Index(1),1}; %��ʼ��
m=1; % ������¼��Ԫ�ص���Ŀ
for i=2:I
    Temp=Label_Mass{Index(i),1};
    %�Ƚ��½�ԪTemp��ǰi-1����Ԫ�����ǲ������ظ��ģ�
    flag=1;
    for j=1:i-1
        if isequal(Temp,Label_Mass{Index(j),1})==1 %�������ͬ��
            flag=0;
            break
        end
    end
    if flag==1
        m=m+1;
        Focal{1,m}=Temp; %�����µĽ�Ԫ
    end
end

%��������õ�ÿ����Ԫ�ط���massֵ
Mass=zeros(1,m); %ÿ����Ԫ���µ�massֵ
for i=1:I
    for j=1:m
        if isequal(Label_Mass{Index(i),1},Focal{1,j})==1
            Mass(1,j)=Mass(1,j)+Label_Mass{Index(i),2};
            break
        end
    end
end
Mass=Mass/I;
Mass_remaining=1-sum(Mass); %��ʾ�����������ʶ����µ�mass

%�����Ӻ���,��mass������Ӧ��ÿ��������Ԫ�ص�pignisticֵ
Probability_vector=Pignistic(Focal,Mass,Mass_remaining,Number); 

%��������ڵ���ֵ
EntS=0;
for i=1:Number
    if Probability_vector>0
       EntS=EntS-Probability_vector(1,i)*log2(Probability_vector(1,i));
    end
end

end

    
    





