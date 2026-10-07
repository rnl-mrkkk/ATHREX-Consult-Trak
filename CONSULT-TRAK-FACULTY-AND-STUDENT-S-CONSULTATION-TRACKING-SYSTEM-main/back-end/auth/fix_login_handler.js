function handleLoginSubmit(event) {
    event.preventDefault();
    var u = document.querySelector ? document.querySelector('input[name="email"]') || document.getElementById('username') : null;
    var p = document.querySelector ? document.querySelector('input[name="password"]') || document.getElementById('password') : null;
    var btn = document.getElementById ? document.getElementById('loginBtn') : null;
    if (!u || !p || !u.value || !p.value) { alert('Fill all fields'); return; }
    if (btn) { btn.disabled = true; btn.textContent = 'Logging in...'; }
    fetch('../back-end/auth/login.php', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email: u.value, password: p.value }) })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.status === 'success') {
            localStorage.setItem('userSession', JSON.stringify({ role: data.user.role, email: data.user.email, user_id: data.user.user_id }));
            window.location.href = '../' + data.user.role.toLowerCase() + '/dashboard.html';
        } else {
            alert(data.message || 'Login failed');
            if (btn) { btn.disabled = false; btn.textContent = 'Login'; }
        }
    }).catch(function() {
        alert('Server unreachable');
        if (btn) { btn.disabled = false; btn.textContent = 'Login'; }
    });
}
