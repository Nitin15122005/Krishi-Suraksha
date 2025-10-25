import { auth } from './firebase.js';
import { signOut, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/11.0.1/firebase-auth.js";

// Function to inject the header into any page
export function loadHeader(containerId) {
  const container = document.getElementById(containerId);
  if (!container) {
    console.error(`Container with ID '${containerId}' not found`);
    return;
  }

  container.innerHTML = `
    <header class="flex justify-between items-center bg-white shadow-sm border-b border-beige-200 p-4">
      <div class="flex items-center space-x-4">
        <div class="h-10 w-10 bg-green-600 rounded-full flex items-center justify-center text-white font-bold">GOV</div>
        <h1 class="text-xl font-semibold text-gray-900">Officer Portal</h1>
        <nav class="hidden md:flex space-x-4 ml-6">
          <a href="dashboard.html" class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-lg transition-colors font-medium">Dashboard</a>
          <a href="reports.html" class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-lg transition-colors font-medium">Reports</a>
        </nav>
      </div>
      <div class="flex items-center space-x-4">
        <span id="officerName" class="font-medium text-sm hidden sm:block text-gray-700"></span>
        <button id="darkModeBtn" class="bg-beige-100 text-amber-700 px-3 py-2 rounded-lg hover:bg-beige-200 transition-colors border border-beige-300">
          🌙
        </button>
        <button id="logoutBtn" class="bg-brown-600 hover:bg-brown-700 text-white px-4 py-2 rounded-lg transition-colors font-medium">Logout</button>
      </div>
    </header>
  `;

  // Set officer name dynamically
  onAuthStateChanged(auth, (user) => {
    if (user) {
      const officerNameElement = document.getElementById('officerName');
      if (officerNameElement) {
        officerNameElement.textContent = user.email;
      }
    }
  });

  // Logout button functionality
  const logoutBtn = document.getElementById('logoutBtn');
  if (logoutBtn) {
    logoutBtn.addEventListener('click', async () => {
      try {
        await signOut(auth);
        window.location.href = "login.html";
      } catch (error) {
        console.error("Logout error:", error);
        alert("Logout failed: " + error.message);
      }
    });
  }

  // Dark Mode toggle
  const darkModeBtn = document.getElementById('darkModeBtn');
  if (darkModeBtn) {
    const isDarkMode = localStorage.theme === 'dark' || 
      (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches);
    
    if (isDarkMode) {
      document.documentElement.classList.add('dark');
      darkModeBtn.textContent = '☀️';
      darkModeBtn.classList.add('bg-amber-200', 'text-amber-900');
      darkModeBtn.classList.remove('bg-beige-100', 'text-amber-700');
    } else {
      document.documentElement.classList.remove('dark');
      darkModeBtn.textContent = '🌙';
      darkModeBtn.classList.add('bg-beige-100', 'text-amber-700');
      darkModeBtn.classList.remove('bg-amber-200', 'text-amber-900');
    }

    darkModeBtn.addEventListener('click', () => {
      if (document.documentElement.classList.contains('dark')) {
        document.documentElement.classList.remove('dark');
        localStorage.theme = 'light';
        darkModeBtn.textContent = '🌙';
        darkModeBtn.classList.add('bg-beige-100', 'text-amber-700');
        darkModeBtn.classList.remove('bg-amber-200', 'text-amber-900');
      } else {
        document.documentElement.classList.add('dark');
        localStorage.theme = 'dark';
        darkModeBtn.textContent = '☀️';
        darkModeBtn.classList.add('bg-amber-200', 'text-amber-900');
        darkModeBtn.classList.remove('bg-beige-100', 'text-amber-700');
      }
    });
  }
}

// Add custom styles for the header
const style = document.createElement('style');
style.textContent = `
  .bg-beige-100 { background-color: #fdf6e3; }
  .bg-beige-200 { background-color: #faf0d7; }
  .border-beige-200 { border-color: #faf0d7; }
  .border-beige-300 { border-color: #e5d5b8; }
  
  .bg-green-600 { background-color: #16a34a; }
  .bg-brown-600 { background-color: #92400e; }
  .bg-brown-700 { background-color: #78350f; }
  
  .bg-amber-200 { background-color: #fde68a; }
  .text-amber-700 { color: #b45309; }
  .text-amber-900 { color: #78350f; }
  
  /* Dark mode support */
  .dark header {
    background-color: #1f2937;
    border-color: #374151;
  }
  .dark .text-gray-900 { color: #f9fafb; }
  .dark .text-gray-700 { color: #d1d5db; }
  .dark a:hover {
    color: #34d399;
  }
`;
document.head.appendChild(style);