%�Ӻ�������������ֵ���У����������Լ���Ӧÿ������ֵ�����������ǩ���а�Ԫ�������ض�λ�õ�������������ֵ
%���룺X--����ֵ����������Label_Mass-��Ӧ������ֵ�����������mass������N*2�İ�Ԫ���ֱ�洢��Ԫ���Լ���Ӧmassֵ
%     Index--����������ʾ������Ƕ�Ӧ��Щλ�õ����ݼ���

function EntS=Entropy_interval(Index,Label_Mass)

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

%����1����������ʶ���Ҳ��Ϊ���е�һ����Ԫ��
% Mass_remaining=1-sum(Mass); %��ʾ�����������ʶ����µ�mass
% %��������ڵ���ֵ
% EntS=0;
% for i=1:m
%     EntS=EntS-Mass(1,i)*log2(Mass(1,i));
% end
% if Mass_remaining>0 %��������������ʶ��ܵ�mass����0�����ⲿ��Ҳ������ȥ
%     EntS=EntS-Mass_remaining*log2(Mass_remaining);
% end

%����2��������ʶ��ܲ���Ϊ��Ԫ�أ�������mass���й�һ����������ж���ʱ��ͳ�����ǩ����Ŀһ�£�������������ʶ��ܣ�
 Mass=Mass/sum(Mass);
 EntS=0;
 for i=1:m
     EntS=EntS-Mass(1,i)*log2(Mass(1,i));
 end

end

 



    
    















