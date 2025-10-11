// No-results analytics only
(() => {
    const MAX_WAIT_MS = 8000;
    const POLL_INTERVAL_MS = 200;
    let flushed = false;
    const queue = [];

    const enqueueOrSend = (event, props) => {
        if (typeof window.plausible === 'function') {
            window.plausible(event, { props });
            flushed = true;
        } else {
            queue.push([event, props]);
        }
    };

    const flushQueueIfReady = () => {
        if (flushed) return true;
        if (typeof window.plausible !== 'function') return false;
        while (queue.length) {
            const [e, p] = queue.shift();
            window.plausible(e, { props: p });
        }
        flushed = true;
        return true;
    };

    const startPolling = () => {
        const start = Date.now();
        const tick = () => {
            if (flushQueueIfReady()) return;
            if (Date.now() - start >= MAX_WAIT_MS) return; // give up silently
            setTimeout(tick, POLL_INTERVAL_MS);
        };
        tick();
    };

    document.addEventListener('DOMContentLoaded', () => {
        const el = document.getElementById('search_no_results');
        if (!el) return;

        const query = el.dataset.query || '';

        // Inject UTM params (only if not already set)
        try {
            const url = new URL(window.location.href);
            const alreadyTagged = url.searchParams.get('utm_source') === 'internal_search'
                && url.searchParams.get('utm_medium') === 'no_results';
            if (!alreadyTagged) {
                url.searchParams.set('utm_source', 'internal_search');
                url.searchParams.set('utm_medium', 'no_results');
                url.searchParams.set('utm_campaign', 'search');
                url.searchParams.set('utm_term', query);
                window.history.replaceState({}, '', url);
            }
        } catch (_) {
            // Ignore URL manipulation errors
        }

        enqueueOrSend('Search no results', { query });
        flushQueueIfReady();
        if (!flushed) startPolling();
    });

    // Also attempt flush after full load as a fallback
    window.addEventListener('load', flushQueueIfReady);
})();
