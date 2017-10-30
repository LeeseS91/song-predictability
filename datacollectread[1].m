function [cell_pattern, cell_count, cell_probs,cell_entropy, jjmark, nmark]...
    = datacollectread(j,peice, N, cell_pattern, cell_count, cell_probs, n)


jjmark=0;
nmark=0;
    if j>=n
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

       
end

