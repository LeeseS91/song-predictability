function [threshold]=meanlimfunc(cell_entropy, jjmark, x, M, j, N)
% find mean threshold if meanlim is selected

if j<M
    if n<N
        if jjmark~=0
            initscoreent(j,n)=(2^(n-1))*(1-cell_entropy{n}(jjmark/2+x));
        end
    end
end
if j==M
    for num=1:N-1
        meaninitscore(num)=mean(initscoreent(num:M-1,num));
    end
    meaninitscore(N)=sum(meaninitscore(1:N-1));
    % if specified earlier define the threshold as the mean limit worked
    % out previously.
    if meanlim==1
        threshold=meaninitscore(N);
    end
end
