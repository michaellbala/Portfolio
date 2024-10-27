const apiUrl = 'https://api.jikan.moe/v4/seasons/now';

document.addEventListener('DOMContentLoaded', () => {
    fetchManhwa();
  });
  
const currentYear = new Date().getFullYear();

async function fetchManhwa() {
    const url = `${apiUrl}`; // Replace with appropriate endpoint for manhwa if available

    try {
        const response = await fetch(url);
        const data = await response.json();
        displayManhwa(data.data);
    } catch (error) {
        console.error('Error fetching data:', error);
        alert('Failed to fetch data. Please try again.');
    }
}

function displayManhwa(manhwaList) {
    const container = document.getElementById('manhwa-container');
    container.innerHTML = '';

    manhwaList.forEach(manhwa => {
        const card = document.createElement('div');
        card.classList.add('bg-white', 'border', 'border-gray-200', 'rounded-lg', 'shadow-md', 'overflow-hidden', 'transition-transform', 'transform', 'hover:scale-105');

        const img = document.createElement('img');
        img.src = manhwa.images.jpg.image_url;
        img.alt = manhwa.title;
        img.classList.add('w-fit', 'h-48', 'object-cover', 'align-middle', 'm-auto', 'mt-4');

        const content = document.createElement('div');
        content.classList.add('p-4');

        const title = document.createElement('h2');
        title.textContent = manhwa.title;
        title.classList.add('text-xl', 'font-semibold', 'mb-2');

        const rating = document.createElement('h3');
        rating.textContent = `Rating: ${manhwa.score}`;
        rating.classList.add('text-red-600', 'text-sm', 'font-semibold', 'mb-2');

        const episodes = document.createElement('p');
        episodes.textContent = `Episodes: ${manhwa.episodes}`;
        episodes.classList.add('text-gray-600', 'text-sm', 'font-semibold', 'mb-2');

        const description = document.createElement('p');
        description.textContent = manhwa.synopsis ? manhwa.synopsis.substring(0, 100) + '...' : 'No description available';
        description.classList.add('text-gray-600', 'text-sm');

        content.appendChild(title);
        content.appendChild(rating);
        content.appendChild(episodes);
        content.appendChild(description);
        card.appendChild(img);
        card.appendChild(content);
        container.appendChild(card);
    });
}
