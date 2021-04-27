%2019.8.25
%�Ӻ��������ɹ���Ľ�����
%input: Activated_degree--1*M cell; Discounted_factor--1*M ������
%Output:Combination_result--1*M ������

function  Combination_result=Combination(Activated_degree,Discounted_factor)

M=length(Activated_degree); %�洢�����Ŀ
Mass=zeros(1,M+1); %�洢û�б���һ����mass�ںϽ��
temp1=ones(1,M); %�洢һ�����˻���ֵ
temp2=ones(1,M); %�洢��ȫ�������е�Ԫ��
for s=1:M
    if isempty(Activated_degree{1,s})==0
        temp1(1,s)=prod(ones-Activated_degree{1,s});
        temp2(1,s)=Discounted_factor(1,s)*temp1(1,s)+1-Discounted_factor(1,s);
    end
end

%���������Ӧ��massֵ
Mass(1,M+1)=prod(temp2); 
for s=1:M
    Mass(1,s)=Discounted_factor(1,s)*(1-temp1(1,s))*prod(temp2(1,[1:s-1 s+1:M]));
end

%������й�һ��
Combination_result=zeros(1,M+1);
for s=1:M+1
    Combination_result(1,s)=Mass(1,s)/sum(Mass); 
end

end


