function [peice, scoreent, count, change, changeindex, ...
    equalcount, equalindex, calc, j] = prednext2(j, peice, scoreent, count, probsarray, t, change, ...
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

if rem(j-M,t)==0 && j>M
    tnum=t;
    % make predictions as to the next note in the peice
    if  mean(scoreent(j-(M-1)-tnum:j-(M-1),end))>threshold %suprise(count)<=initsuprisefact-1 %
        change=change+1;
        changeindex(change:change+t-1)=j+1:j+t;
        change=change+t-1;
        peice(j+1:j+t)=randi(2,[1,t])-1;
        j=j+t-1;
%         startind=startind+1;
%         start=(startind*t)-(startind);
        calc=1;
    else
        if size(maxprob,2)>1
            peice(j+1)=randi(2,1)-1;
            equalcount=equalcount+1;
            equalindex(equalcount)=j+1;
        elseif maxprob==1;
            peice(j+1)=0;
        elseif maxprob==2
            peice(j+1)=1;
        end
        calc=0;
%         j=j;
    end
else
    if size(maxprob,2)>1
        peice(j+1)=randi(2,1)-1;
        equalcount=equalcount+1;
        equalindex(equalcount)=j+1;
    elseif maxprob==1;
        peice(j+1)=0;
    elseif maxprob==2
        peice(j+1)=1;
        
        
    end
    %         clear probsindex
    %         clear probsarray
    %         clear maxindex
    %         clear index
    %         clear maxprob
    %         clear probmin
    %         clear probmax
    calc=0;
%     j=j;
end

end