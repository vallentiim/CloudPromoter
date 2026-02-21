
        document.addEventListener('DOMContentLoaded', () => {
            // Obter dados do usuário da sessão
            // const user = getUserData();
            // document.getElementById(‘username’).textContent = user.name;
            

            document.getElementById('username').textContent = 'User';
        });
        
        // BOTÕES
        document.querySelector('.btn-outline').addEventListener('click', () => {
            alert('Redirecionando para criação de nova campanha...');
        });
        
        document.querySelector('.btn').addEventListener('click', () => {
            alert('Abrindo formulário de chamado...');
        });