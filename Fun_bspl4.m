function result=Fun_bspl4(i,X,node,period,order)
%% Debug
% nodeLT=[0,4,8,12,16,20,24];
% i=4;X=12:0.1:16;node=nodeLT;
%%
%order=4;
t_t=reshape(node,1,length(node));
%t_t=[t_t  t_t+period  t_t+period*2  3*period];
t_t=[t_t  t_t(1:order)+period];
%%%
result=nan+zeros(size(X));
for num=1:length(X)
    x=X(num);
    if i>0, if x<t_t(i), x=x+period; end; end;
    for j=i:i+order-1
        if x>=t_t(j) && x<t_t(j+1)
           b(j,1)=1;
        else
           b(j,1)=0;
        end;
    end;
%%
    for j=2:order
        for k=i:i+order-j
            
            if (x-t_t(k))==0 && (t_t(k+j-1)-t_t(k))==0 
                b(k,j)=0*b(k,j-1);
            elseif (t_t(k+j-1)-t_t(k))==0 
                b(k,j)=(x-t_t(k))/1*b(k,j-1);
            else
                b(k,j)=(x-t_t(k))/(t_t(k+j-1)-t_t(k))*b(k,j-1);
            end
            if (t_t(k+j)-x)==0 && (t_t(k+j)-t_t(k+1))==0 
                b(k,j)=b(k,j)+0*b(k+1,j-1);
            elseif (t_t(k+j)-t_t(k+1))==0
                b(k,j)=b(k,j)+(t_t(k+j)-x)/1*b(k+1,j-1);
            else
                b(k,j)=b(k,j)+(t_t(k+j)-x)/(t_t(k+j)-t_t(k+1))*b(k+1,j-1);
            end
        end;
    end;
    result(num)=b(i,order);
end;    
%%%%%%%%%%%%% The End of the Code;