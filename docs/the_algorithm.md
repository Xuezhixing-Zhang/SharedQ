## Algorithm 1: Joint ridge Q-learning (knowledge-sharing DTR)

1. **Starting values.** Consider a DTR with \(K\) stages. Let  
   \[
   \mathcal{H}_k=\{(O_1,A_1,\ldots,O_k,A_k,O_{k+1})\}
   \]
   be the history at stage \(k\), where \(O_k\) denotes the covariates measured prior to treatment at the beginning of the \(k\)-th stage and \(A_k\) is the treatment assigned at the \(k\)-th stage subsequent to observing \(O_k\), for \(k=1,\ldots,K\). Finally, \(O_{K+1}\) is the observation at the end of stage \(K\) (end of study).

   Let \(Z_k\) be the design matrix fitted at stage \(k\). Define  
   \[
   \theta^T=(\beta_1^T,\psi_1^T,\ldots,\beta_K^T,\psi_K^T),
   \]
   where \(\beta_k\) and \(\psi_k\) represent the stage-specific parameters and candidate shared parameters at stage \(k\), respectively.

2. **Iterate for \(t=0,1,2,\ldots\)**

   **(a)** Form pseudo-outcomes  
   \[
   Y_k^*(\hat{\theta}^{(t)}).
   \]

   **(b)** Update \(\hat{\psi}_{1:K}^{(t+1)}\): obtain \(\hat{\psi}_{1:K}^{(t+1)}\) as the minimizer of  
   \[
   \sum_k
   \left\|
   Y_k^{*(t)} - Z_k^T \hat{\psi}_k^{(t)}
   \right\|_2^2
   +
   \lambda
   \sum_{k=1}^{K-1}
   \left\|
   \psi_k-\psi_{k+1}
   \right\|_2^2 .
   \]

3. **Convergence.** Repeat 2(a) and 2(b). Stop when  
   \[
   \left\|
   \hat{\theta}^{(t+1)}-\hat{\theta}^{(t)}
   \right\|_2 < \epsilon .
   \]