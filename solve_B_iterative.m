function [B] = solve_B_iterative(coils_r, coils_dl, coils_t, I, N, domain_r, mu0)
B = zeros(size(domain_r,1),3);

tic
for i = 1:length(coils_r)
    for j = 1:size(domain_r,1)
        r_q_temp = repmat(domain_r(j,:), [length(coils_r{i}), 1]);
        r_rel = (r_q_temp-coils_r{i});
        temp_integral = coils_dl{i}.*cross(coils_t{i},r_rel)./sqrt(r_rel(:,1).^2 + ...
            r_rel(:,2).^2 + r_rel(:,3).^2).^3;
        B_temp = (mu0/(4*pi))*I(i)*N(i)*sum(temp_integral,1);
        B(j,:) = B(j,:) + B_temp;
    end
end
toc

end