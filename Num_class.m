%�Ӻ������ж���ĳЩ����λ���µ����������ǩ�����Ŀ
%���룺Index-����������ʾλ�������� Ambiguous_label--���ǩ����Ӧÿ��ѵ�����������ǩ���а�Ԫ 

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

% ���Ǳ�ʶ���(��Ӧ�ڷ���1����������ʶ���Ҳ��Ϊ���е�һ����Ԫ��)
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

