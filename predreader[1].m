function [peice, equalcount, equalindex] = predreader(j, peice, probsarray,equalcount, equalindex)

% as we dont want to start predicting before j reaches end of random gen



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

        peice(j+1)=0;

elseif maxprob==2

        peice(j+1)=1;

end

clear probsindex
clear probsarray
clear maxindex
clear index
clear maxprob
clear probmin
clear probmax

end

