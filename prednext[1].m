function [peice, scoreent, count, change, changeindex, ...
    equalcount, equalindex] = prednext(j, peice, scoreent, count, probsarray, change, ...
    changeindex, equalcount, equalindex, M, N, threshold)

% as we dont want to start predicting before j reaches end of random gen

scoreent(j-(M-1),N)=sum(scoreent(j-(M-1),:));
count=count+1;

if size(probsarray,1)==1
    maxprob=find(probsarray==max(probsarray));
else
    format long
    newprobs=sum(probsarray);
    maxprob=find(newprobs==max(newprobs));
end

% make predictions as to the next note in the peice
if size(maxprob,2)>1
    peice(j+1)=randi(2,1)-1;
    equalcount=equalcount+1;
    equalindex(equalcount)=j+1;
elseif maxprob==1;
    if  scoreent(j-(M-1),end)>threshold %suprise(count)<=initsuprisefact-1 %
        change=change+1;
        changeindex(change)=j+1;
        peice(j+1)=1;
    else
        peice(j+1)=0;
    end
elseif maxprob==2
    if scoreent(j-(M-1),end)>threshold %suprise(count)<=initsuprisefact-1
        change=change+1;
        changeindex(change)=j+1;
        peice(j+1)=0;
    else
        peice(j+1)=1;
    end
end

clear probsindex
clear probsarray
clear maxindex
clear index
clear maxprob
clear probmin
clear probmax

end

