function [cell_pattern, cell_count, cell_probs,cell_entropy, threshold, jjmark]...
    = datacollect(j,peice, N, M, MAX, cell_pattern, cell_count, ...
    cell_probs, cell_entropy, threshold, meanlim, n)


jjmark=0;
    if j>=n && j<=M+MAX-n
        for jj=1:size(cell_pattern{n},1)
            if peice(j-(n-1):j)==cell_pattern{n,1}(jj,:)
                cell_pattern{n,2}(jj)=cell_pattern{n,2}(jj)+1;
                jjmark=jj;
                if rem(jjmark/2,1)~=0
                    x=0.5;
                    nmark=1;
                else
                    x=0;
                    nmark=2;
                end
                cell_count{n}((jjmark/2)+x,nmark)=cell_count{n}((jjmark/2)+x,nmark)+1;
                break
            end
        end
        % update probabilities with new cell counts
        for f=1:size(cell_count{n},1)
            if cell_count{n}(f,1)+cell_count{n}(f,2)~=0
                cell_probs{n}(f,1)=cell_count{n}(f,1)/(cell_count{n}(f,1)+cell_count{n}(f,2));
                cell_probs{n}(f,2)=cell_count{n}(f,2)/(cell_count{n}(f,1)+cell_count{n}(f,2));
            end
        end
    end
    cell_entropy=calcentropy(cell_probs,N);
    
    if meanlim==1
    [threshold]=meanlimfunc(cell_entropy, jjmark, x, M, j, N);
    end
       
    % want to create a probabililty array once j reaches end of
    % rand gen and calculate it using appropriate prob function
    % for the n value.
    %         if n>1
%     if j>=M
%         if n<N
%             if jjmark~=0
%                 scoreent(j-(M-1),n)=(2^(n-1))*(1-cell_entropy{n+1}(jjmark));
%                 %(2^(n-1))*
%                 probsarray(n,:)=(2^(n-1))*(1-cell_entropy{n+1}(jjmark))*cell_probs{n+1}(jjmark, :);
%                 jjmark=0;
%                 nmark=0;
%             end
%         end
%     else 
%         scoreent=zeros(1,2);
%         probsarray=zeros(1,2);
%     end
    
end

